import Foundation
import PDFKit

struct FileScanner {
    private let fileManager = FileManager.default

    func searchFiles(
        in rootPath: String,
        contentKeyword: String,
        includeHidden: Bool = false,
        maxFileSizeBytes: Int = 15_000_000
    ) throws -> [URL] {
        let rootURL = URL(fileURLWithPath: rootPath)
        var isDir: ObjCBool = false
        guard fileManager.fileExists(atPath: rootURL.path, isDirectory: &isDir), isDir.boolValue else {
            throw AppError.invalidDirectory
        }

        let keys: [URLResourceKey] = [.isDirectoryKey, .isRegularFileKey, .isHiddenKey, .fileSizeKey]
        guard let enumerator = fileManager.enumerator(
            at: rootURL,
            includingPropertiesForKeys: keys,
            options: includeHidden ? [] : [.skipsHiddenFiles]
        ) else {
            throw AppError.invalidDirectory
        }

        let needle = contentKeyword.trimmingCharacters(in: .whitespacesAndNewlines)
        if needle.isEmpty {
            throw AppError.invalidInput("内容关键字不能为空")
        }

        var matched: [URL] = []
        for case let url as URL in enumerator {
            let values = try? url.resourceValues(forKeys: Set(keys))
            guard values?.isRegularFile == true else { continue }
            let size = values?.fileSize ?? 0
            if size <= 0 || size > maxFileSizeBytes { continue }

            if containsKeyword(url: url, keyword: needle) {
                matched.append(url)
            }
        }

        return matched
    }

    private func containsKeyword(url: URL, keyword: String) -> Bool {
        if let text = extractText(for: url) {
            return text.localizedCaseInsensitiveContains(keyword)
        }
        return false
    }

    private func extractText(for url: URL) -> String? {
        let ext = url.pathExtension.lowercased()

        if ext == "pdf" {
            return extractPDFText(url)
        }

        if ["docx", "xlsx", "pptx"].contains(ext) {
            return extractOfficeOpenXMLText(url: url, ext: ext)
        }

        return extractPlainText(url)
    }

    private func extractPlainText(_ url: URL) -> String? {
        guard let data = try? Data(contentsOf: url, options: [.mappedIfSafe]) else { return nil }

        if let content = String(data: data, encoding: .utf8) {
            return content
        }
        if let content = String(data: data, encoding: .unicode) {
            return content
        }
        if let content = String(data: data, encoding: .ascii) {
            return content
        }
        return nil
    }

    private func extractPDFText(_ url: URL) -> String? {
        guard let doc = PDFDocument(url: url) else { return nil }
        var full = ""
        for index in 0..<doc.pageCount {
            if let page = doc.page(at: index), let text = page.string {
                full += text
                full += "\n"
            }
        }
        return full.isEmpty ? nil : full
    }

    private func extractOfficeOpenXMLText(url: URL, ext: String) -> String? {
        let entries: [String]
        switch ext {
        case "docx":
            entries = ["word/document.xml", "word/header1.xml", "word/footer1.xml"]
        case "xlsx":
            entries = ["xl/sharedStrings.xml", "xl/worksheets/sheet1.xml"]
        case "pptx":
            entries = ["ppt/slides/slide1.xml", "ppt/slides/slide2.xml", "ppt/slides/slide3.xml"]
        default:
            entries = []
        }

        let availableEntries = listZipEntries(at: url)
        if availableEntries.isEmpty {
            return nil
        }

        let targetEntries = availableEntries.filter { entry in
            entries.contains(where: { entry.hasPrefix($0.replacingOccurrences(of: "1.xml", with: "")) })
                || entry.hasSuffix(".xml")
        }

        var allText = ""
        for entry in targetEntries {
            guard let xml = unzipEntry(at: url, entry: entry) else { continue }
            allText += stripXML(xml)
            allText += "\n"
        }

        return allText.isEmpty ? nil : allText
    }

    private func listZipEntries(at url: URL) -> [String] {
        let result = runProcess("/usr/bin/zipinfo", ["-1", url.path])
        guard result.status == 0 else { return [] }
        return result.output
            .split(separator: "\n")
            .map(String.init)
    }

    private func unzipEntry(at url: URL, entry: String) -> String? {
        let result = runProcess("/usr/bin/unzip", ["-p", url.path, entry])
        guard result.status == 0 else { return nil }
        return result.output
    }

    private func stripXML(_ xml: String) -> String {
        let noTags = xml.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
        return noTags.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }

    private func runProcess(_ launchPath: String, _ arguments: [String]) -> (status: Int32, output: String) {
        let process = Process()
        let outPipe = Pipe()
        process.executableURL = URL(fileURLWithPath: launchPath)
        process.arguments = arguments
        process.standardOutput = outPipe
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()
            let data = outPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            return (process.terminationStatus, output)
        } catch {
            return (1, "")
        }
    }
}
