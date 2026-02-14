import Foundation
import Darwin
import PDFKit

struct MetadataService {
    private let fileManager = FileManager.default
    private let customPrefix = "com.pdflibrarian."
    private let exifToolCandidatePaths = [
        "/opt/homebrew/bin/exiftool",
        "/usr/local/bin/exiftool",
        "/usr/bin/exiftool"
    ]
    private let bundledExifToolRelativePaths = [
        "ExifTool/bin/exiftool",
        "exiftool"
    ]

    private struct ExifToolCommand {
        let executable: String
        let prefixArguments: [String]
    }

    func readMetadata(for fileURL: URL) throws -> [String: String] {
        try withSecurityScopedAccess(to: fileURL) {
            var result: [String: String] = [:]
            let values = try fileURL.resourceValues(forKeys: [
                .nameKey,
                .fileSizeKey,
                .creationDateKey,
                .contentModificationDateKey,
                .tagNamesKey,
                .typeIdentifierKey,
                .localizedTypeDescriptionKey
            ])

            result["path"] = fileURL.path
            result["name"] = values.name ?? fileURL.lastPathComponent
            result["extension"] = fileURL.pathExtension
            if let size = values.fileSize {
                result["size"] = String(size)
            }
            if let creationDate = values.creationDate {
                result["createdAt"] = ISO8601DateFormatter().string(from: creationDate)
            }
            if let modificationDate = values.contentModificationDate {
                result["modifiedAt"] = ISO8601DateFormatter().string(from: modificationDate)
            }
            if let tags = values.tagNames, !tags.isEmpty {
                result["finder.tags"] = tags.joined(separator: ",")
            }
            if let uti = values.typeIdentifier {
                result["uti"] = uti
            }
            if let typeDesc = values.localizedTypeDescription {
                result["typeDescription"] = typeDesc
            }

            for (key, value) in try readCustomXAttrs(fileURL: fileURL) {
                result[key] = value
            }

            return result
        }
    }

    func writeMetadata(fileURL: URL, key: String, value: String) throws {
        try withSecurityScopedAccess(to: fileURL) {
            try writeMetadataInternal(fileURL: fileURL, key: key, value: value)
        }
    }

    private func writeMetadataInternal(fileURL: URL, key: String, value: String) throws {
        let cleanKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanKey.isEmpty {
            throw AppError.invalidInput("metadata key 不能为空")
        }

        if isPDF(fileURL) {
            let assignments = exifToolAssignments(for: cleanKey, value: value)
            if !assignments.isEmpty {
                try writePDFDublinCoreWithExifTool(fileURL: fileURL, assignments: assignments)
                return
            }
        }

        if cleanKey == "finder.tags" {
            let tags = value
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }

            if #available(macOS 26.0, *) {
                var values = URLResourceValues()
                values.tagNames = tags
                var mutableURL = fileURL
                try mutableURL.setResourceValues(values)
            } else {
                throw AppError.invalidInput("当前系统不支持通过此 API 写入 finder.tags，请使用自定义键")
            }
            return
        }

        try writeCustomXAttr(fileURL: fileURL, key: cleanKey, value: value)
    }

    func writeMetadata(fileURL: URL, entries: [String: String]) throws {
        try withSecurityScopedAccess(to: fileURL) {
            var fallbackEntries: [(key: String, value: String)] = []
            var pdfAssignments: [String] = []

            for (rawKey, rawValue) in entries {
                let cleanKey = rawKey.trimmingCharacters(in: .whitespacesAndNewlines)
                let cleanValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)

                if cleanKey.isEmpty {
                    throw AppError.invalidInput("metadata key 不能为空")
                }
                if cleanValue.isEmpty {
                    continue
                }

                if isPDF(fileURL) {
                    let assignments = exifToolAssignments(for: cleanKey, value: cleanValue)
                    if !assignments.isEmpty {
                        pdfAssignments.append(contentsOf: assignments)
                    } else {
                        fallbackEntries.append((cleanKey, cleanValue))
                    }
                } else {
                    fallbackEntries.append((cleanKey, cleanValue))
                }
            }

            if !pdfAssignments.isEmpty {
                try writePDFDublinCoreWithExifTool(fileURL: fileURL, assignments: pdfAssignments)
            }

            for entry in fallbackEntries {
                try writeMetadataInternal(fileURL: fileURL, key: entry.key, value: entry.value)
            }
        }
    }

    private func isPDF(_ fileURL: URL) -> Bool {
        fileURL.pathExtension.lowercased() == "pdf"
    }

    private func exifToolAssignments(for key: String, value: String) -> [String] {
        let cleanValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanValue.isEmpty {
            return []
        }

        switch key {
        case "dc:title":
            return [
                "-XMP-dc:Title=\(cleanValue)",
                "-XMP-dc:Title-x-default=\(cleanValue)",
                "-PDF:Title=\(cleanValue)"
            ]
        case "dc:creator":
            return [
                "-XMP-dc:Creator=\(cleanValue)",
                "-PDF:Author=\(cleanValue)"
            ]
        case "dc:publisher":
            return ["-XMP-dc:Publisher=\(cleanValue)"]
        case "dc:date":
            return ["-XMP-dc:Date=\(cleanValue)"]
        case "dc:language":
            return [
                "-XMP-dc:Language=\(cleanValue)",
                "-PDF:Lang=\(cleanValue)"
            ]
        case "dc:type":
            return ["-XMP-dc:Type=\(cleanValue)"]
        case "dc:format":
            return ["-XMP-dc:Format=\(cleanValue)"]
        case "dc:identifier":
            return ["-XMP-dc:Identifier=\(cleanValue)"]
        case "dc:subject":
            return [
                "-XMP-dc:Subject=\(cleanValue)",
                "-PDF:Subject=\(cleanValue)",
                "-PDF:Keywords=\(cleanValue)",
                "-XMP-pdf:Keywords=\(cleanValue)"
            ]
        case "dc:source":
            return ["-XMP-dc:Source=\(cleanValue)"]
        case "dc:relation":
            return ["-XMP-dc:Relation=\(cleanValue)"]
        case "dc:description":
            return [
                "-XMP-dc:Description=\(cleanValue)",
                "-XMP-dc:Description-x-default=\(cleanValue)"
            ]
        default:
            return []
        }
    }

    private func writePDFDublinCoreWithExifTool(fileURL: URL, assignments: [String]) throws {
        if assignments.isEmpty {
            return
        }

        guard let exifToolPath = resolveExifToolPath() else {
            throw AppError.invalidInput("未找到内置 exiftool，也未在系统路径发现 exiftool。请重新打包应用以包含 exiftool。")
        }
        let commands = resolveExifToolCommands(exifToolPath: exifToolPath)
        let workspaceURL = fileManager.temporaryDirectory
            .appendingPathComponent("metadata-write-\(UUID().uuidString)", isDirectory: true)
        let workingPDFURL = workspaceURL.appendingPathComponent(fileURL.lastPathComponent)

        do {
            try fileManager.createDirectory(at: workspaceURL, withIntermediateDirectories: true)
            try fileManager.copyItem(at: fileURL, to: workingPDFURL)
        } catch {
            throw AppError.invalidInput("创建 PDF 临时副本失败: \(error.localizedDescription)")
        }
        defer {
            try? fileManager.removeItem(at: workspaceURL)
        }

        try removeAllXAttrs(fileURL: workingPDFURL)

        // Clear all embedded metadata first, then write the mapped Dublin Core fields.
        let exifToolArgs = ["-overwrite_original", "-P", "-all="] + assignments + [workingPDFURL.path]
        var launchErrors: [String] = []
        var lastExecutionError: String?
        var writeSucceeded = false

        for command in commands {
            let args = command.prefixArguments + exifToolArgs
            let result = runProcess(command.executable, args)

            if !result.didLaunch {
                launchErrors.append("\(command.executable): \(result.stderr)")
                continue
            }

            if result.code == 0 {
                writeSucceeded = true
                break
            }

            let message = [result.stderr, result.stdout]
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .joined(separator: "\n")
            let finalMessage = message.isEmpty ? "exiftool failed with code \(result.code)" : message
            if isLikelyProcessLaunchError(finalMessage) {
                launchErrors.append("\(command.executable): \(finalMessage)")
                continue
            }
            lastExecutionError = finalMessage
            break
        }

        if !writeSucceeded {
            if let lastExecutionError {
                throw AppError.invalidInput("exiftool 写入 PDF XMP 失败: \(lastExecutionError)")
            }
            let fallbackMessage = launchErrors.isEmpty ? "未知启动错误" : launchErrors.joined(separator: " | ")
            throw AppError.invalidInput("exiftool 启动失败: \(fallbackMessage)")
        }

        try rewritePDFWithoutIncrementalHistory(fileURL: workingPDFURL)

        do {
            _ = try fileManager.replaceItemAt(
                fileURL,
                withItemAt: workingPDFURL,
                backupItemName: nil,
                options: [.usingNewMetadataOnly]
            )
            try removeAllXAttrs(fileURL: fileURL)
        } catch {
            throw AppError.invalidInput("写回 PDF 失败: \(error.localizedDescription)")
        }
    }

    private func resolveExifToolPath() -> String? {
        if let resourcesPath = Bundle.main.resourcePath {
            for relativePath in bundledExifToolRelativePaths {
                let candidate = URL(fileURLWithPath: resourcesPath).appendingPathComponent(relativePath).path
                if fileManager.isExecutableFile(atPath: candidate) {
                    return candidate
                }
            }
        }

        if let bundled = Bundle.main.path(forResource: "exiftool", ofType: nil),
           fileManager.isExecutableFile(atPath: bundled) {
            return bundled
        }

        if let executablePath = Bundle.main.executablePath {
            let executableDir = URL(fileURLWithPath: executablePath).deletingLastPathComponent()
            let embeddedCandidate = executableDir
                .deletingLastPathComponent()
                .appendingPathComponent("Resources/ExifTool/bin/exiftool")
                .path
            if fileManager.isExecutableFile(atPath: embeddedCandidate) {
                return embeddedCandidate
            }
        }

        for path in exifToolCandidatePaths where fileManager.isExecutableFile(atPath: path) {
            return path
        }

        let pathItems = (ProcessInfo.processInfo.environment["PATH"] ?? "")
            .split(separator: ":")
            .map(String.init)
        for dir in pathItems {
            let candidate = URL(fileURLWithPath: dir).appendingPathComponent("exiftool").path
            if fileManager.isExecutableFile(atPath: candidate) {
                return candidate
            }
        }

        return nil
    }

    private func resolveExifToolCommands(exifToolPath: String) -> [ExifToolCommand] {
        if isBundledExifToolPath(exifToolPath) {
            var candidates: [ExifToolCommand] = [
                ExifToolCommand(executable: exifToolPath, prefixArguments: [])
            ]

            if fileManager.isExecutableFile(atPath: "/usr/bin/perl") {
                candidates.append(ExifToolCommand(executable: "/usr/bin/perl", prefixArguments: [exifToolPath]))
            }
            if fileManager.isExecutableFile(atPath: "/usr/bin/env") {
                candidates.append(ExifToolCommand(executable: "/usr/bin/env", prefixArguments: ["perl", exifToolPath]))
            }

            var unique: [ExifToolCommand] = []
            var seen = Set<String>()
            for command in candidates {
                let key = command.executable + "|" + command.prefixArguments.joined(separator: "\u{1f}")
                if seen.insert(key).inserted {
                    unique.append(command)
                }
            }
            return unique
        }
        return [ExifToolCommand(executable: exifToolPath, prefixArguments: [])]
    }

    private func isBundledExifToolPath(_ path: String) -> Bool {
        path.contains("/Contents/Resources/ExifTool/bin/exiftool") || path.hasSuffix("/ExifTool/bin/exiftool")
    }

    private func isLikelyProcessLaunchError(_ message: String) -> Bool {
        let lower = message.lowercased()
        return lower.contains("permission denied")
            || lower.contains("operation not permitted")
            || lower.contains("no such file")
            || lower.contains("posixspawn")
    }

    private func removeAllXAttrs(fileURL: URL) throws {
        let names = try listXAttrNamesStrict(fileURL: fileURL)
        if names.isEmpty {
            return
        }

        var failures: [String] = []
        for name in names {
            if removexattr(fileURL.path, name, 0) != 0 {
                let errorCode = errno
                if errorCode == ENOATTR {
                    continue
                }
                let reason = String(cString: strerror(errorCode))
                failures.append("\(name)(\(reason))")
            }
        }

        if !failures.isEmpty {
            throw AppError.invalidInput("清空 xattr 失败: \(failures.joined(separator: ", "))")
        }
    }

    private func listXAttrNamesStrict(fileURL: URL) throws -> [String] {
        let listSize = listxattr(fileURL.path, nil, 0, 0)
        if listSize < 0 {
            let reason = String(cString: strerror(errno))
            throw AppError.invalidInput("读取 xattr 列表失败: \(reason)")
        }
        if listSize == 0 {
            return []
        }

        var nameBuffer = [CChar](repeating: 0, count: listSize)
        let actual = listxattr(fileURL.path, &nameBuffer, nameBuffer.count, 0)
        if actual < 0 {
            let reason = String(cString: strerror(errno))
            throw AppError.invalidInput("读取 xattr 列表失败: \(reason)")
        }
        return splitNullTerminatedCString(nameBuffer)
    }

    private func listXAttrNames(fileURL: URL) throws -> [String] {
        let listSize = listxattr(fileURL.path, nil, 0, 0)
        if listSize < 0 || listSize == 0 {
            return []
        }

        var nameBuffer = [CChar](repeating: 0, count: listSize)
        let actual = listxattr(fileURL.path, &nameBuffer, nameBuffer.count, 0)
        if actual < 0 {
            return []
        }
        return splitNullTerminatedCString(nameBuffer)
    }

    private func runProcess(_ executable: String, _ arguments: [String]) -> (code: Int32, stdout: String, stderr: String, didLaunch: Bool) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        do {
            try process.run()
            process.waitUntilExit()
            let outData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let errData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            return (
                process.terminationStatus,
                String(data: outData, encoding: .utf8) ?? "",
                String(data: errData, encoding: .utf8) ?? "",
                true
            )
        } catch {
            let nsError = error as NSError
            let message = "\(error.localizedDescription) (domain=\(nsError.domain), code=\(nsError.code), executable=\(executable))"
            return (1, "", message, false)
        }
    }

    private func withSecurityScopedAccess<T>(to fileURL: URL, operation: () throws -> T) throws -> T {
        let didStartAccess = fileURL.startAccessingSecurityScopedResource()
        defer {
            if didStartAccess {
                fileURL.stopAccessingSecurityScopedResource()
            }
        }
        return try operation()
    }

    private func rewritePDFWithoutIncrementalHistory(fileURL: URL) throws {
        guard let document = PDFDocument(url: fileURL) else {
            throw AppError.readFailure(fileURL)
        }

        let tempURL = fileURL
            .deletingLastPathComponent()
            .appendingPathComponent(".metadata-rewrite-\(UUID().uuidString).pdf")

        guard document.write(to: tempURL) else {
            throw AppError.writeFailure(tempURL)
        }

        do {
            _ = try fileManager.replaceItemAt(fileURL, withItemAt: tempURL)
        } catch {
            throw AppError.moveFailure(tempURL, fileURL)
        }
    }

    private func writeCustomXAttr(fileURL: URL, key: String, value: String) throws {
        let attrName = customPrefix + key
        guard let bytes = value.data(using: .utf8) else {
            throw AppError.invalidInput("metadata value 必须是 UTF-8 文本")
        }

        let status = bytes.withUnsafeBytes { ptr in
            setxattr(fileURL.path, attrName, ptr.baseAddress, bytes.count, 0, 0)
        }

        if status != 0 {
            throw AppError.writeFailure(fileURL)
        }
    }

    private func readCustomXAttrs(fileURL: URL) throws -> [String: String] {
        let names = try listXAttrNames(fileURL: fileURL)
        var entries: [String: String] = [:]
        for fullName in names where fullName.hasPrefix(customPrefix) {
            let valueSize = getxattr(fileURL.path, fullName, nil, 0, 0, 0)
            if valueSize <= 0 { continue }

            var valueBuffer = [UInt8](repeating: 0, count: valueSize)
            let readBytes = getxattr(fileURL.path, fullName, &valueBuffer, valueBuffer.count, 0, 0)
            if readBytes <= 0 { continue }

            let data = Data(valueBuffer.prefix(readBytes))
            guard let text = String(data: data, encoding: .utf8) else { continue }
            let plainKey = String(fullName.dropFirst(customPrefix.count))
            entries[plainKey] = text
        }

        return entries
    }

    private func splitNullTerminatedCString(_ buffer: [CChar]) -> [String] {
        var names: [String] = []
        var current: [CChar] = []

        for char in buffer {
            if char == 0 {
                if !current.isEmpty {
                    current.append(0)
                    names.append(String(cString: current))
                    current.removeAll(keepingCapacity: true)
                }
            } else {
                current.append(char)
            }
        }

        return names
    }
}
