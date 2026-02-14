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
            return AppLocalization.text(.publicationBook)
        case .paper:
            return AppLocalization.text(.publicationPaper)
        case .unknown:
            return AppLocalization.text(.publicationUnknown)
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
            return AppLocalization.text(.stageLoaded)
        case .searched:
            return AppLocalization.text(.stageSearched)
        case .written:
            return AppLocalization.text(.stageWritten)
        case .renamed:
            return AppLocalization.text(.stageRenamed)
        case .renameSkipped:
            return AppLocalization.text(.stageRenameSkipped)
        case .failed:
            return AppLocalization.text(.stageFailed)
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
        if authors.isEmpty { return AppLocalization.text(.unknownAuthor) }
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
            return AppLocalization.text(.errorInvalidDirectory)
        case .invalidFile:
            return AppLocalization.text(.errorInvalidFile)
        case .invalidInput(let value):
            return AppLocalization.format(.errorInvalidInput, arguments: [value])
        case .readFailure(let url):
            return AppLocalization.format(.errorReadFailure, arguments: [url.path])
        case .writeFailure(let url):
            return AppLocalization.format(.errorWriteFailure, arguments: [url.path])
        case .moveFailure(let from, let to):
            return AppLocalization.format(.errorMoveFailure, arguments: [from.path, to.path])
        case .networkFailure(let message):
            return AppLocalization.format(.errorNetworkFailure, arguments: [message])
        }
    }
}
