import Foundation

struct BookRenameService {
    private let fileManager = FileManager.default

    func suggestedFileName(for candidate: BookMetadataCandidate, originalExtension: String = "pdf") -> String {
        let title = sanitizeFieldToken(tokenOrFallback(candidate.title, fallback: "UnknownTitle"))
        let author = sanitizeFieldToken(tokenOrFallback(shortAuthorText(from: candidate.authors), fallback: "UnknownAuthor"))
        let publisher = sanitizeFieldToken(tokenOrFallback(candidate.publisher, fallback: "UnknownPublisher"))
        let year = sanitizeFieldToken(tokenOrFallback(candidate.publishedYear, fallback: "UnknownYear"))
        let language = sanitizeFieldToken(tokenOrFallback(candidate.language, fallback: "unknown"))

        let base = [title, author, publisher, year, language].joined(separator: "_")
        let ext = originalExtension.isEmpty ? "pdf" : originalExtension
        return "\(sanitizeFileName(base)).\(ext)"
    }

    func renameFile(at fileURL: URL, using candidate: BookMetadataCandidate) throws -> URL {
        let suggested = suggestedFileName(for: candidate, originalExtension: fileURL.pathExtension)
        let targetURL = uniqueURL(in: fileURL.deletingLastPathComponent(), fileName: suggested)

        do {
            try fileManager.moveItem(at: fileURL, to: targetURL)
            return targetURL
        } catch {
            throw AppError.moveFailure(fileURL, targetURL)
        }
    }

    private func shortAuthorText(from authors: [String]) -> String {
        let cleanAuthors = authors
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard let first = cleanAuthors.first else {
            return "UnknownAuthor"
        }

        if cleanAuthors.count > 1 {
            return first
        }

        return first
    }

    private func uniqueURL(in directory: URL, fileName: String) -> URL {
        let desired = directory.appendingPathComponent(fileName)
        if !fileManager.fileExists(atPath: desired.path) {
            return desired
        }

        let ext = desired.pathExtension
        let base = desired.deletingPathExtension().lastPathComponent
        var index = 1

        while true {
            let candidateName: String
            if ext.isEmpty {
                candidateName = "\(base)_\(index)"
            } else {
                candidateName = "\(base)_\(index).\(ext)"
            }
            let candidateURL = directory.appendingPathComponent(candidateName)
            if !fileManager.fileExists(atPath: candidateURL.path) {
                return candidateURL
            }
            index += 1
        }
    }

    private func sanitizeFieldToken(_ raw: String) -> String {
        let invalid = CharacterSet(charactersIn: "/:\\?%*|\"<>")
        let converted = raw.unicodeScalars.map { invalid.contains($0) ? Character(".") : Character($0) }

        return String(converted)
            .replacingOccurrences(of: "_", with: ".")
            .replacingOccurrences(of: "\\s+", with: ".", options: .regularExpression)
            .replacingOccurrences(of: "\\.+", with: ".", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "._ ").union(.whitespacesAndNewlines))
    }

    private func sanitizeFileName(_ raw: String) -> String {
        let invalid = CharacterSet(charactersIn: "/:\\?%*|\"<>")
        let converted = raw.unicodeScalars.map { invalid.contains($0) ? Character(".") : Character($0) }

        return String(converted)
            .replacingOccurrences(of: "\\s+", with: ".", options: .regularExpression)
            .replacingOccurrences(of: "\\.+", with: ".", options: .regularExpression)
            .replacingOccurrences(of: "_+", with: "_", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "._ ").union(.whitespacesAndNewlines))
    }

    private func tokenOrFallback(_ raw: String, fallback: String) -> String {
        let clean = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return clean.isEmpty ? fallback : clean
    }
}
