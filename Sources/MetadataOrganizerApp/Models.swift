import Foundation

struct FileRecord: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let metadata: [String: String]
}

enum PublicationKind: String, Hashable, Codable {
    case book
    case paper
    case unknown

    var displayName: String {
        switch self {
        case .book:
            return "书籍"
        case .paper:
            return "文献"
        case .unknown:
            return "未知"
        }
    }
}

enum PDFWorkflowStage: String, Hashable {
    case loaded
    case searched
    case written
    case renamed
    case renameSkipped
    case failed

    var displayName: String {
        switch self {
        case .loaded:
            return "已加载"
        case .searched:
            return "已检索"
        case .written:
            return "已写入"
        case .renamed:
            return "已重命名"
        case .renameSkipped:
            return "已跳过重命名"
        case .failed:
            return "错误"
        }
    }
}

struct PDFSearchHint: Hashable {
    let fileNameTitle: String
    let extractedTitle: String
    let snippet: String
    let isbn: String?
    let doi: String?
    let queryCandidates: [String]
}

struct BookMetadataCandidate: Identifiable, Hashable {
    let id = UUID()
    var kind: PublicationKind
    var title: String
    var subtitle: String
    var authors: [String]
    var publisher: String
    var publishedYear: String
    var language: String
    var isbn: String
    var doi: String
    var source: String
    var sourceURL: String
    var validatedBy: [String]
    var confidence: Int

    var primaryTitle: String {
        if subtitle.isEmpty { return title }
        return "\(title): \(subtitle)"
    }

    var authorsText: String {
        if authors.isEmpty { return "未知作者" }
        return authors.joined(separator: ", ")
    }
}

struct PDFWorkItem: Identifiable, Hashable {
    let id = UUID()
    var url: URL
    var hint: PDFSearchHint
    var candidates: [BookMetadataCandidate] = []
    var selectedCandidateID: UUID?
    var stage: PDFWorkflowStage = .loaded
    var lastError: String = ""
}

struct MetadataSourceOptions: Hashable {
    var useGoogleBooks: Bool = true
    var useOpenLibrary: Bool = true
    var useDoubanWebSearch: Bool = true
    var useLibraryOfCongress: Bool = true
    var useSemanticScholar: Bool = true
    var semanticScholarAPIKey: String = ""
}

enum AppError: LocalizedError {
    case invalidDirectory
    case invalidFile
    case invalidInput(String)
    case readFailure(URL)
    case writeFailure(URL)
    case moveFailure(URL, URL)
    case networkFailure(String)

    var errorDescription: String? {
        switch self {
        case .invalidDirectory:
            return "目录不存在或不可访问。"
        case .invalidFile:
            return "请选择 PDF 文件或包含 PDF 的目录。"
        case .invalidInput(let value):
            return "输入无效: \(value)"
        case .readFailure(let url):
            return "读取失败: \(url.path)"
        case .writeFailure(let url):
            return "写入失败: \(url.path)"
        case .moveFailure(let from, let to):
            return "移动失败: \(from.path) -> \(to.path)"
        case .networkFailure(let message):
            return "网络请求失败: \(message)"
        }
    }
}
