import Foundation

struct SearchRule: Hashable {
    var createdFrom: Date?
    var createdTo: Date?
    var requiredTags: [String]
    var fileNameRegex: String
    var metadataKey: String
    var metadataRegex: String

    var isEmpty: Bool {
        createdFrom == nil
            && createdTo == nil
            && requiredTags.isEmpty
            && fileNameRegex.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && metadataKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && metadataRegex.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

struct RuleEngine {
    private let iso = ISO8601DateFormatter()

    func filter(records: [FileRecord], rule: SearchRule) -> [FileRecord] {
        if rule.isEmpty { return records }

        let fileRegex = compileRegex(rule.fileNameRegex)
        let metadataRegex = compileRegex(rule.metadataRegex)
        let metadataKey = rule.metadataKey.trimmingCharacters(in: .whitespacesAndNewlines)

        return records.filter { record in
            if let createdFrom = rule.createdFrom {
                guard let createdAt = parseDate(record.metadata["createdAt"]), createdAt >= createdFrom else {
                    return false
                }
            }
            if let createdTo = rule.createdTo {
                guard let createdAt = parseDate(record.metadata["createdAt"]), createdAt <= createdTo else {
                    return false
                }
            }

            if !rule.requiredTags.isEmpty {
                let tags = parseTags(record.metadata["finder.tags"])
                let required = Set(rule.requiredTags.map { $0.lowercased() })
                if !required.isSubset(of: Set(tags.map { $0.lowercased() })) {
                    return false
                }
            }

            if let fileRegex {
                let range = NSRange(record.url.lastPathComponent.startIndex..., in: record.url.lastPathComponent)
                if fileRegex.firstMatch(in: record.url.lastPathComponent, range: range) == nil {
                    return false
                }
            }

            if let metadataRegex {
                guard !metadataKey.isEmpty else { return false }
                let value = record.metadata[metadataKey] ?? ""
                let range = NSRange(value.startIndex..., in: value)
                if metadataRegex.firstMatch(in: value, range: range) == nil {
                    return false
                }
            }

            return true
        }
    }

    private func parseDate(_ raw: String?) -> Date? {
        guard let raw else { return nil }
        return iso.date(from: raw)
    }

    private func parseTags(_ raw: String?) -> [String] {
        guard let raw, !raw.isEmpty else { return [] }
        return raw
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private func compileRegex(_ pattern: String) -> NSRegularExpression? {
        let clean = pattern.trimmingCharacters(in: .whitespacesAndNewlines)
        if clean.isEmpty { return nil }
        return try? NSRegularExpression(pattern: clean, options: [.caseInsensitive])
    }
}
