import Foundation
import Darwin

struct MetadataService {
    private let fileManager = FileManager.default
    private let customPrefix = "com.metadataorganizer."

    func readMetadata(for fileURL: URL) throws -> [String: String] {
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

    func writeMetadata(fileURL: URL, key: String, value: String) throws {
        let cleanKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanKey.isEmpty {
            throw AppError.invalidInput("metadata key 不能为空")
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
        for (key, value) in entries {
            if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                continue
            }
            try writeMetadata(fileURL: fileURL, key: key, value: value)
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
        let listSize = listxattr(fileURL.path, nil, 0, 0)
        if listSize < 0 {
            return [:]
        }
        if listSize == 0 {
            return [:]
        }

        var nameBuffer = [CChar](repeating: 0, count: listSize)
        let actual = listxattr(fileURL.path, &nameBuffer, nameBuffer.count, 0)
        if actual < 0 {
            return [:]
        }

        var entries: [String: String] = [:]
        let names = splitNullTerminatedCString(nameBuffer)
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
