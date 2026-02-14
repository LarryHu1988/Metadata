import Foundation

enum OrganizeStrategy: Hashable {
    case byExtension
    case byMetadataKey(String)
}

struct RenameOrganizerService {
    private let fileManager = FileManager.default
    private let metadataService = MetadataService()

    func rename(
        files: [URL],
        template: String,
        dryRun: Bool
    ) throws -> [String] {
        if template.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw AppError.invalidInput("重命名模板不能为空")
        }

        var logs: [String] = []
        for file in files {
            let metadata = try metadataService.readMetadata(for: file)
            let newBaseName = sanitizeFileName(renderTemplate(template, for: file, metadata: metadata))

            if newBaseName.isEmpty {
                logs.append("跳过 \(file.lastPathComponent): 生成的新文件名为空")
                continue
            }

            let ext = file.pathExtension
            let finalName = ext.isEmpty ? newBaseName : "\(newBaseName).\(ext)"
            let target = uniqueTargetURL(
                for: file.deletingLastPathComponent().appendingPathComponent(finalName),
                excluding: file
            )

            if dryRun {
                logs.append("[DRY] \(file.lastPathComponent) -> \(target.lastPathComponent)")
            } else {
                do {
                    if isSameFileURL(file, target) {
                        logs.append("保持不变: \(file.lastPathComponent)")
                    } else {
                        try fileManager.moveItem(at: file, to: target)
                        logs.append("已重命名: \(file.lastPathComponent) -> \(target.lastPathComponent)")
                    }
                } catch {
                    logs.append("失败: \(file.lastPathComponent) -> \(target.lastPathComponent), \(error.localizedDescription)")
                }
            }
        }

        return logs
    }

    func organize(
        files: [URL],
        destinationRoot: URL,
        strategy: OrganizeStrategy,
        dryRun: Bool
    ) throws -> [String] {
        var isDir: ObjCBool = false
        guard fileManager.fileExists(atPath: destinationRoot.path, isDirectory: &isDir), isDir.boolValue else {
            throw AppError.invalidDirectory
        }

        var logs: [String] = []
        for file in files {
            let metadata = try metadataService.readMetadata(for: file)
            let folderName: String

            switch strategy {
            case .byExtension:
                folderName = file.pathExtension.isEmpty ? "no_extension" : file.pathExtension.lowercased()
            case .byMetadataKey(let key):
                folderName = sanitizeFileName(metadata[key] ?? "unknown")
            }

            let targetDir = destinationRoot.appendingPathComponent(folderName.isEmpty ? "unknown" : folderName)
            let targetFile = uniqueTargetURL(
                for: targetDir.appendingPathComponent(file.lastPathComponent),
                excluding: file
            )

            if dryRun {
                logs.append("[DRY] \(file.path) -> \(targetFile.path)")
                continue
            }

            do {
                if isSameFileURL(file, targetFile) {
                    logs.append("保持不变: \(file.lastPathComponent)")
                } else {
                    try fileManager.createDirectory(at: targetDir, withIntermediateDirectories: true)
                    try fileManager.moveItem(at: file, to: targetFile)
                    logs.append("已整理: \(file.lastPathComponent) -> \(targetDir.lastPathComponent)/")
                }
            } catch {
                logs.append("失败: \(file.path) -> \(targetFile.path), \(error.localizedDescription)")
            }
        }

        return logs
    }

    private func renderTemplate(_ template: String, for file: URL, metadata: [String: String]) -> String {
        var result = template
        let builtins: [String: String] = [
            "name": file.deletingPathExtension().lastPathComponent,
            "ext": file.pathExtension,
            "date": DateFormatter.templateDate.string(from: Date())
        ]

        for (key, value) in builtins {
            result = result.replacingOccurrences(of: "{\(key)}", with: value)
        }

        let regexPattern = #"\{meta:([^}]+)\}"#
        guard let regex = try? NSRegularExpression(pattern: regexPattern) else {
            return result
        }
        let matches = regex.matches(in: result, range: NSRange(result.startIndex..., in: result)).reversed()
        for match in matches {
            guard
                match.numberOfRanges == 2,
                let totalRange = Range(match.range(at: 0), in: result),
                let keyRange = Range(match.range(at: 1), in: result)
            else { continue }

            let key = String(result[keyRange])
            let replacement = metadata[key] ?? ""
            result.replaceSubrange(totalRange, with: replacement)
        }

        return result
    }

    private func uniqueTargetURL(for desiredURL: URL, excluding sourceURL: URL?) -> URL {
        if let sourceURL, isSameFileURL(desiredURL, sourceURL) {
            return desiredURL
        }
        if !fileManager.fileExists(atPath: desiredURL.path) {
            return desiredURL
        }

        let base = desiredURL.deletingPathExtension().lastPathComponent
        let ext = desiredURL.pathExtension
        let dir = desiredURL.deletingLastPathComponent()

        var index = 1
        while true {
            let candidateName: String
            if ext.isEmpty {
                candidateName = "\(base)_\(index)"
            } else {
                candidateName = "\(base)_\(index).\(ext)"
            }
            let candidate = dir.appendingPathComponent(candidateName)
            if let sourceURL, isSameFileURL(candidate, sourceURL) {
                return candidate
            }
            if !fileManager.fileExists(atPath: candidate.path) {
                return candidate
            }
            index += 1
        }
    }

    private func sanitizeFileName(_ source: String) -> String {
        let invalid = CharacterSet(charactersIn: "/:\\?%*|\"<>")
        let cleanedScalars = source.unicodeScalars.map { invalid.contains($0) ? "_" : Character($0) }
        let cleaned = String(cleanedScalars)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: "_")
        return cleaned
    }

    private func isSameFileURL(_ lhs: URL, _ rhs: URL) -> Bool {
        lhs.standardizedFileURL.path == rhs.standardizedFileURL.path
    }
}

private extension DateFormatter {
    static let templateDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter
    }()
}
