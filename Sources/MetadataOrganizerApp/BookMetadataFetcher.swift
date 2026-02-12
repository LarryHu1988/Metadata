import Foundation

final class BookMetadataFetcher {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchCandidates(hint: PDFSearchHint, options: MetadataSourceOptions) async -> [BookMetadataCandidate] {
        var pool: [BookMetadataCandidate] = []

        if options.useOpenLibrary {
            pool.append(contentsOf: await fetchFromOpenLibraryPrimary(hint: hint))
        }

        if options.useGoogleBooks {
            pool.append(contentsOf: await fetchFromGoogleBooksSupplement(hint: hint))
        }

        var merged = rankAndDedupe(pool, hint: hint)

        if options.useLoCValidation || options.useWorldCatValidation {
            merged = await validateWithLoCAndWorldCat(candidates: merged, hint: hint, options: options)
        }

        return merged.sorted {
            if $0.confidence == $1.confidence {
                return $0.primaryTitle.localizedCaseInsensitiveCompare($1.primaryTitle) == .orderedAscending
            }
            return $0.confidence > $1.confidence
        }
    }

    private func fetchFromOpenLibraryPrimary(hint: PDFSearchHint) async -> [BookMetadataCandidate] {
        var results: [BookMetadataCandidate] = []

        var queryPlans: [(queryItems: [URLQueryItem], baseConfidence: Int)] = []
        if let isbn = hint.isbn, !isbn.isEmpty {
            queryPlans.append(([
                URLQueryItem(name: "isbn", value: isbn),
                URLQueryItem(name: "limit", value: "8"),
                URLQueryItem(name: "fields", value: openLibraryFields)
            ], 66))
        }

        for title in hint.queryCandidates.prefix(3) {
            queryPlans.append(([
                URLQueryItem(name: "title", value: title),
                URLQueryItem(name: "limit", value: "8"),
                URLQueryItem(name: "fields", value: openLibraryFields)
            ], 56))
        }

        for plan in queryPlans {
            guard var comps = URLComponents(string: "https://openlibrary.org/search.json") else { continue }
            comps.queryItems = plan.queryItems

            guard let url = comps.url,
                  let data = try? await requestData(url: url),
                  let payload = try? JSONDecoder().decode(OpenLibrarySearchResponse.self, from: data)
            else {
                continue
            }

            for doc in payload.docs ?? [] {
                guard let title = doc.title, !title.isEmpty else { continue }

                let subtitle = doc.subtitle ?? ""
                let authors = doc.authorName ?? []
                let publisher = doc.publisher?.first ?? ""
                let year = doc.firstPublishYear.map(String.init) ?? ""
                let isbn = normalizeISBN(doc.isbn?.first ?? "")
                let language = normalizeLanguage(doc.language?.first ?? "")
                let sourceURL = doc.key.map { "https://openlibrary.org\($0)" } ?? ""

                results.append(
                    BookMetadataCandidate(
                        kind: .book,
                        title: title,
                        subtitle: subtitle,
                        authors: authors,
                        publisher: publisher,
                        publishedYear: year,
                        language: language,
                        isbn: isbn,
                        doi: "",
                        source: "OpenLibrary",
                        sourceURL: sourceURL,
                        validatedBy: [],
                        confidence: plan.baseConfidence
                    )
                )
            }
        }

        return results
    }

    private func fetchFromGoogleBooksSupplement(hint: PDFSearchHint) async -> [BookMetadataCandidate] {
        var results: [BookMetadataCandidate] = []

        var queries: [String] = []
        if let isbn = hint.isbn, !isbn.isEmpty {
            queries.append("isbn:\(isbn)")
        }
        queries.append(contentsOf: hint.queryCandidates.prefix(2))

        for query in queries {
            guard var comps = URLComponents(string: "https://www.googleapis.com/books/v1/volumes") else { continue }
            comps.queryItems = [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "maxResults", value: "6"),
                URLQueryItem(name: "printType", value: "books")
            ]

            guard let url = comps.url,
                  let data = try? await requestData(url: url),
                  let payload = try? JSONDecoder().decode(GoogleVolumesResponse.self, from: data)
            else {
                continue
            }

            for item in payload.items ?? [] {
                guard let info = item.volumeInfo,
                      let title = info.title,
                      !title.isEmpty
                else {
                    continue
                }

                let subtitle = info.subtitle ?? ""
                let authors = info.authors ?? []
                let publisher = info.publisher ?? ""
                let year = firstYear(in: info.publishedDate) ?? ""
                let language = normalizeLanguage(info.language ?? "")
                let isbn = bestGoogleISBN(info.industryIdentifiers)

                results.append(
                    BookMetadataCandidate(
                        kind: .book,
                        title: title,
                        subtitle: subtitle,
                        authors: authors,
                        publisher: publisher,
                        publishedYear: year,
                        language: language,
                        isbn: isbn,
                        doi: "",
                        source: "Google Books",
                        sourceURL: info.infoLink ?? "",
                        validatedBy: [],
                        confidence: 46
                    )
                )
            }
        }

        return results
    }

    private func validateWithLoCAndWorldCat(
        candidates: [BookMetadataCandidate],
        hint: PDFSearchHint,
        options: MetadataSourceOptions
    ) async -> [BookMetadataCandidate] {
        var updated = candidates
        var signalCache: [String: ValidationSignals] = [:]

        let isbnSet: Set<String> = {
            var result = Set(updated.map { normalizeISBN($0.isbn) }.filter { !$0.isEmpty })
            let hintISBN = normalizeISBN(hint.isbn ?? "")
            if !hintISBN.isEmpty {
                result.insert(hintISBN)
            }
            return result
        }()

        let worldCatByISBN: [String: WorldCatBriefRecord]
        if options.useWorldCatValidation {
            worldCatByISBN = await fetchWorldCatRecords(byISBNs: Array(isbnSet), options: options)
        } else {
            worldCatByISBN = [:]
        }

        let maxLoCChecks = min(6, updated.count)

        for index in updated.indices {
            var candidate = updated[index]
            var checks = Set(candidate.validatedBy)

            let isbn = normalizeISBN(candidate.isbn.isEmpty ? (hint.isbn ?? "") : candidate.isbn)
            if !isbn.isEmpty, signalCache[isbn] == nil {
                signalCache[isbn] = await fetchEditionValidationSignals(isbn: isbn)
            }

            if let signals = signalCache[isbn], !isbn.isEmpty {
                if options.useLoCValidation, signals.locMatched {
                    checks.insert("LoC")
                    candidate.confidence += 8
                }

                if options.useWorldCatValidation, signals.worldcatMatched {
                    checks.insert("WorldCat")
                    candidate.confidence += 5
                }

                if candidate.language.isEmpty, let lang = signals.language, !lang.isEmpty {
                    candidate.language = lang
                }
            }

            if options.useWorldCatValidation,
               !isbn.isEmpty,
               let wc = worldCatByISBN[isbn] {
                checks.insert("WorldCatAPI")
                candidate.confidence += 12

                if candidate.language.isEmpty { candidate.language = wc.language }
                if candidate.publisher.isEmpty { candidate.publisher = wc.publisher }
                if candidate.publishedYear.isEmpty { candidate.publishedYear = wc.publishedYear }
            }

            if options.useLoCValidation, index < maxLoCChecks {
                let query = "\(candidate.title) \(candidate.authors.first ?? "")"
                if await existsInLoC(query: query) {
                    checks.insert("LoC")
                    candidate.confidence += 5
                }
            }

            candidate.validatedBy = checks.sorted()
            candidate.confidence = min(candidate.confidence, 99)
            updated[index] = candidate
        }

        return updated
    }

    private func fetchEditionValidationSignals(isbn: String) async -> ValidationSignals {
        guard let url = URL(string: "https://openlibrary.org/isbn/\(isbn).json"),
              let data = try? await requestData(url: url),
              let payload = try? JSONDecoder().decode(OpenLibraryEditionResponse.self, from: data)
        else {
            return ValidationSignals(locMatched: false, worldcatMatched: false, language: nil)
        }

        let sourceRecords = payload.sourceRecords ?? []
        let locMatched = sourceRecords.contains(where: { $0.lowercased().contains("marc_loc") })
        let worldcatMatched = !(payload.oclcNumbers ?? []).isEmpty

        var language: String?
        if let key = payload.languages?.first?.key {
            language = normalizeLanguage(key)
        }

        return ValidationSignals(locMatched: locMatched, worldcatMatched: worldcatMatched, language: language)
    }

    private func fetchWorldCatRecords(
        byISBNs isbns: [String],
        options: MetadataSourceOptions
    ) async -> [String: WorldCatBriefRecord] {
        let key = options.worldCatAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let secret = options.worldCatAPISecret.trimmingCharacters(in: .whitespacesAndNewlines)
        if key.isEmpty || secret.isEmpty {
            return [:]
        }

        guard let token = await requestWorldCatToken(apiKey: key, apiSecret: secret, scope: options.worldCatScope) else {
            return [:]
        }

        var result: [String: WorldCatBriefRecord] = [:]
        for isbn in isbns where !isbn.isEmpty {
            if let record = await fetchWorldCatBriefByISBN(isbn: isbn, accessToken: token) {
                result[isbn] = record
            }
        }

        return result
    }

    private func requestWorldCatToken(apiKey: String, apiSecret: String, scope: String) async -> String? {
        guard let url = URL(string: "https://oauth.oclc.org/token") else { return nil }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.timeoutInterval = 20

        let credential = "\(apiKey):\(apiSecret)"
        guard let credentialData = credential.data(using: .utf8) else { return nil }
        let base64 = credentialData.base64EncodedString()

        let cleanScope = scope.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "wcapi" : scope
        let form = "grant_type=client_credentials&scope=\(cleanScope.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "wcapi")"

        req.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.httpBody = form.data(using: .utf8)

        guard let data = try? await requestData(request: req),
              let payload = try? JSONDecoder().decode(WorldCatTokenResponse.self, from: data),
              !payload.accessToken.isEmpty
        else {
            return nil
        }

        return payload.accessToken
    }

    private func fetchWorldCatBriefByISBN(isbn: String, accessToken: String) async -> WorldCatBriefRecord? {
        guard var comps = URLComponents(string: "https://americas.discovery.api.oclc.org/worldcat/search/v2/brief-bibs") else {
            return nil
        }

        comps.queryItems = [
            URLQueryItem(name: "q", value: "bn:\(isbn)"),
            URLQueryItem(name: "limit", value: "1")
        ]

        guard let url = comps.url else { return nil }

        var req = URLRequest(url: url)
        req.timeoutInterval = 20
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        guard let data = try? await requestData(request: req),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let records = json["briefRecords"] as? [[String: Any]],
              let first = records.first
        else {
            return nil
        }

        return parseWorldCatBriefRecord(first)
    }

    private func parseWorldCatBriefRecord(_ raw: [String: Any]) -> WorldCatBriefRecord {
        let title = firstString(from: raw["title"])
            ?? firstString(from: raw["mainTitle"])
            ?? ""

        let creator = firstString(from: raw["creator"])
            ?? firstString(from: raw["contributors"])
            ?? ""

        let publisher = firstString(from: raw["publisher"])
            ?? firstString(from: raw["publishers"])
            ?? ""

        let dateValue = firstString(from: raw["date"]) ?? firstString(from: raw["publicationDate"]) ?? ""
        let year = firstYear(in: dateValue) ?? ""

        let language = normalizeLanguage(firstString(from: raw["language"]) ?? firstString(from: raw["languages"]) ?? "")
        let oclcNumber = firstString(from: raw["oclcNumber"]) ?? firstString(from: raw["oclcNumbers"]) ?? ""

        return WorldCatBriefRecord(
            title: title,
            creator: creator,
            publisher: publisher,
            publishedYear: year,
            language: language,
            oclcNumber: oclcNumber
        )
    }

    private func firstString(from value: Any?) -> String? {
        guard let value else { return nil }

        if let text = value as? String {
            let clean = text.trimmingCharacters(in: .whitespacesAndNewlines)
            return clean.isEmpty ? nil : clean
        }

        if let number = value as? NSNumber {
            return number.stringValue
        }

        if let array = value as? [Any] {
            for element in array {
                if let found = firstString(from: element) {
                    return found
                }
            }
        }

        if let dict = value as? [String: Any] {
            for key in ["name", "value", "text", "label"] {
                if let found = firstString(from: dict[key]) {
                    return found
                }
            }
        }

        return nil
    }

    private func existsInLoC(query: String) async -> Bool {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return false }

        guard var comps = URLComponents(string: "https://www.loc.gov/books/") else { return false }
        comps.queryItems = [
            URLQueryItem(name: "fo", value: "json"),
            URLQueryItem(name: "q", value: trimmed)
        ]

        guard let url = comps.url,
              let data = try? await requestData(url: url)
        else {
            return false
        }

        guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return false
        }

        if let content = object["content"] as? [String: Any],
           let results = content["results"] as? [Any],
           !results.isEmpty {
            return true
        }

        if let results = object["results"] as? [Any], !results.isEmpty {
            return true
        }

        return false
    }

    private func rankAndDedupe(_ candidates: [BookMetadataCandidate], hint: PDFSearchHint) -> [BookMetadataCandidate] {
        var bestByKey: [String: BookMetadataCandidate] = [:]

        for raw in candidates {
            var candidate = raw
            candidate.confidence = score(candidate: candidate, hint: hint)

            let key = dedupeKey(for: candidate)
            if let existing = bestByKey[key] {
                if candidate.confidence > existing.confidence {
                    bestByKey[key] = candidate
                }
            } else {
                bestByKey[key] = candidate
            }
        }

        return bestByKey.values.sorted {
            if $0.confidence == $1.confidence {
                return $0.primaryTitle.localizedCaseInsensitiveCompare($1.primaryTitle) == .orderedAscending
            }
            return $0.confidence > $1.confidence
        }
    }

    private func score(candidate: BookMetadataCandidate, hint: PDFSearchHint) -> Int {
        var score = candidate.confidence

        let normalizedTitle = normalizeForCompare(candidate.primaryTitle)
        let localTitle = normalizeForCompare(hint.extractedTitle)
        let fileTitle = normalizeForCompare(hint.fileNameTitle)

        if !localTitle.isEmpty,
           normalizedTitle.contains(localTitle) || localTitle.contains(normalizedTitle) {
            score += 18
        } else if !fileTitle.isEmpty,
                  normalizedTitle.contains(fileTitle) || fileTitle.contains(normalizedTitle) {
            score += 12
        }

        let hintISBN = normalizeISBN(hint.isbn ?? "")
        let candidateISBN = normalizeISBN(candidate.isbn)
        if !hintISBN.isEmpty, !candidateISBN.isEmpty, hintISBN == candidateISBN {
            score += 30
        }

        if !candidate.authors.isEmpty { score += 4 }
        if !candidate.publishedYear.isEmpty { score += 4 }
        if !candidate.language.isEmpty { score += 2 }

        return min(max(score, 10), 99)
    }

    private func dedupeKey(for candidate: BookMetadataCandidate) -> String {
        let isbn = normalizeISBN(candidate.isbn)
        if !isbn.isEmpty {
            return "isbn|\(isbn)"
        }

        let title = normalizeForCompare(candidate.primaryTitle)
        let author = normalizeForCompare(candidate.authors.first ?? "")
        return "title|\(title)|\(author)|\(candidate.publishedYear)"
    }

    private func normalizeLanguage(_ raw: String) -> String {
        let clean = raw
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if clean.isEmpty { return "" }

        if clean.contains("/languages/") {
            return String(clean.split(separator: "/").last ?? "")
        }

        let mapping: [String: String] = [
            "eng": "en",
            "english": "en",
            "fre": "fr",
            "fra": "fr",
            "spa": "es",
            "ger": "de",
            "deu": "de",
            "chi": "zh",
            "zho": "zh",
            "chinese": "zh",
            "jpn": "ja",
            "japanese": "ja"
        ]

        return mapping[clean] ?? clean
    }

    private func bestGoogleISBN(_ identifiers: [GoogleIndustryIdentifier]?) -> String {
        let all = identifiers ?? []

        if let isbn13 = all.first(where: { ($0.type ?? "").uppercased().contains("ISBN_13") })?.identifier {
            return normalizeISBN(isbn13)
        }

        if let isbn10 = all.first(where: { ($0.type ?? "").uppercased().contains("ISBN_10") })?.identifier {
            return normalizeISBN(isbn10)
        }

        return ""
    }

    private func normalizeForCompare(_ raw: String) -> String {
        raw
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9]", with: "", options: .regularExpression)
    }

    private func firstYear(in raw: String?) -> String? {
        guard let raw else { return nil }
        let pattern = #"(1[5-9][0-9]{2}|20[0-9]{2}|21[0-9]{2})"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(raw.startIndex..., in: raw)
        guard let match = regex.firstMatch(in: raw, range: range),
              let swiftRange = Range(match.range, in: raw)
        else {
            return nil
        }
        return String(raw[swiftRange])
    }

    private func normalizeISBN(_ raw: String) -> String {
        raw
            .uppercased()
            .replacingOccurrences(of: "[^0-9X]", with: "", options: .regularExpression)
    }

    private func requestData(url: URL) async throws -> Data {
        var req = URLRequest(url: url)
        req.timeoutInterval = 20
        req.setValue("MetadataOrganizerApp/1.0", forHTTPHeaderField: "User-Agent")
        return try await requestData(request: req)
    }

    private func requestData(request: URLRequest) async throws -> Data {
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode)
        else {
            throw AppError.networkFailure(request.url?.absoluteString ?? "")
        }
        return data
    }

    private let openLibraryFields = [
        "title",
        "subtitle",
        "author_name",
        "first_publish_year",
        "publisher",
        "isbn",
        "language",
        "key"
    ].joined(separator: ",")
}

private struct ValidationSignals {
    let locMatched: Bool
    let worldcatMatched: Bool
    let language: String?
}

private struct WorldCatBriefRecord {
    let title: String
    let creator: String
    let publisher: String
    let publishedYear: String
    let language: String
    let oclcNumber: String
}

private struct WorldCatTokenResponse: Decodable {
    let accessToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

private struct GoogleVolumesResponse: Decodable {
    let items: [GoogleVolume]?
}

private struct GoogleVolume: Decodable {
    let volumeInfo: GoogleVolumeInfo?
}

private struct GoogleVolumeInfo: Decodable {
    let title: String?
    let subtitle: String?
    let authors: [String]?
    let publisher: String?
    let publishedDate: String?
    let industryIdentifiers: [GoogleIndustryIdentifier]?
    let infoLink: String?
    let language: String?
}

private struct GoogleIndustryIdentifier: Decodable {
    let type: String?
    let identifier: String?
}

private struct OpenLibrarySearchResponse: Decodable {
    let docs: [OpenLibraryDoc]?
}

private struct OpenLibraryDoc: Decodable {
    let title: String?
    let subtitle: String?
    let authorName: [String]?
    let firstPublishYear: Int?
    let publisher: [String]?
    let isbn: [String]?
    let language: [String]?
    let key: String?

    enum CodingKeys: String, CodingKey {
        case title
        case subtitle
        case authorName = "author_name"
        case firstPublishYear = "first_publish_year"
        case publisher
        case isbn
        case language
        case key
    }
}

private struct OpenLibraryEditionResponse: Decodable {
    let sourceRecords: [String]?
    let oclcNumbers: [String]?
    let languages: [OpenLibraryLanguageRef]?

    enum CodingKeys: String, CodingKey {
        case sourceRecords = "source_records"
        case oclcNumbers = "oclc_numbers"
        case languages
    }
}

private struct OpenLibraryLanguageRef: Decodable {
    let key: String?
}
