import Foundation

enum AppLanguage: String, CaseIterable, Identifiable, Hashable {
    case simplifiedChinese = "zh-Hans"
    case english = "en"
    case spanish = "es"
    case hindi = "hi"
    case arabic = "ar"
    case french = "fr"
    case portuguese = "pt"
    case russian = "ru"
    case japanese = "ja"
    case german = "de"

    static let supportedTopTen: [AppLanguage] = [
        .simplifiedChinese,
        .english,
        .spanish,
        .hindi,
        .arabic,
        .french,
        .portuguese,
        .russian,
        .japanese,
        .german
    ]

    var id: String { rawValue }

    var localeIdentifier: String {
        switch self {
        case .simplifiedChinese:
            return "zh-Hans"
        default:
            return rawValue
        }
    }

    var nativeName: String {
        switch self {
        case .simplifiedChinese:
            return "简体中文"
        case .english:
            return "English"
        case .spanish:
            return "Español"
        case .hindi:
            return "हिन्दी"
        case .arabic:
            return "العربية"
        case .french:
            return "Français"
        case .portuguese:
            return "Português"
        case .russian:
            return "Русский"
        case .japanese:
            return "日本語"
        case .german:
            return "Deutsch"
        }
    }

    static var systemPreferred: AppLanguage {
        from(code: Locale.preferredLanguages.first) ?? .simplifiedChinese
    }

    static func from(code: String?) -> AppLanguage? {
        guard let code else { return nil }
        if let exact = AppLanguage(rawValue: code) { return exact }

        let lower = code.lowercased()
        if lower.hasPrefix("zh") { return .simplifiedChinese }
        if lower.hasPrefix("en") { return .english }
        if lower.hasPrefix("es") { return .spanish }
        if lower.hasPrefix("hi") { return .hindi }
        if lower.hasPrefix("ar") { return .arabic }
        if lower.hasPrefix("fr") { return .french }
        if lower.hasPrefix("pt") { return .portuguese }
        if lower.hasPrefix("ru") { return .russian }
        if lower.hasPrefix("ja") { return .japanese }
        if lower.hasPrefix("de") { return .german }
        return nil
    }
}

enum AppTextKey {
    case alertWriteTitle
    case buttonCancel
    case buttonConfirmWrite
    case appTitle
    case appSubtitle
    case chipPDFFiles
    case chipCurrentStatus
    case chipVersion
    case chipLanguage
    case flowTitle
    case stepOne
    case stepTwo
    case stepThree
    case stepFour
    case cardOneTitle
    case fieldSelectedPath
    case fieldSelectedPathPlaceholder
    case buttonChoose
    case buttonLoadPDF
    case folderScanHint
    case loadedPDFList
    case noPDFLoaded
    case cardTwoTitle
    case hintFileName
    case hintExtractedTitle
    case hintISBN
    case hintDOI
    case hintSnippet
    case sourceOpenLibrary
    case sourceGoogleBooks
    case sourceDouban
    case sourceLOC
    case buttonSearchMetadata
    case buttonSearching
    case searchStrategy
    case noCandidates
    case loadAndSelectFirst
    case cardThreeTitle
    case selectedCandidate
    case sourceConfidence
    case noSelectedCandidate
    case dublinFieldsTitle
    case fieldValuePlaceholder
    case fieldCurrentValue
    case selectedFieldsCount
    case buttonConfirmWriteDublin
    case editableHint
    case cardFourTitle
    case suggestedFileName
    case renameRule
    case renameRuleNote
    case buttonRename
    case buttonSkipRename
    case noRenamePrompt
    case executionLog
    case noLogs
    case contentHint
    case chipLanguageCode
    case chipValidated
    case stageNotStarted
    case stageLoaded
    case stageSearched
    case stageWritten
    case stageRenamed
    case stageRenameSkipped
    case stageFailed
    case publicationBook
    case publicationPaper
    case publicationUnknown
    case unknownAuthor
    case statusReady
    case statusLanguageChanged
    case statusLoadedCount
    case statusLoadFailed
    case statusSelectPDFFirst
    case statusSearching
    case statusNoMatch
    case statusNoMetadataFound
    case statusSearchComplete
    case statusSelectCandidate
    case statusSelectAtLeastOneField
    case statusWritePreview
    case statusWriteFailedMissingItem
    case statusWriteFailedNoFields
    case statusWriteSuccess
    case statusWriteFailed
    case statusRenameMissingContext
    case statusRenameSuccess
    case statusRenameFailed
    case statusRenameSkipped
    case errorInvalidDirectory
    case errorInvalidFile
    case errorInvalidInput
    case errorReadFailure
    case errorWriteFailure
    case errorMoveFailure
    case errorNetworkFailure
}

enum AppLocalization {
    static var currentLanguage: AppLanguage = .simplifiedChinese

    static func text(_ key: AppTextKey, language: AppLanguage? = nil) -> String {
        let lang = language ?? currentLanguage

        switch lang {
        case .simplifiedChinese:
            return chineseText(key)
        case .english:
            return englishText(key)
        case .spanish:
            return spanishText(key) ?? englishText(key)
        case .hindi:
            return hindiText(key) ?? englishText(key)
        case .arabic:
            return arabicText(key) ?? englishText(key)
        case .french:
            return frenchText(key) ?? englishText(key)
        case .portuguese:
            return portugueseText(key) ?? englishText(key)
        case .russian:
            return russianText(key) ?? englishText(key)
        case .japanese:
            return japaneseText(key) ?? englishText(key)
        case .german:
            return germanText(key) ?? englishText(key)
        }
    }

    static func format(_ key: AppTextKey, language: AppLanguage? = nil, arguments: [CVarArg]) -> String {
        let lang = language ?? currentLanguage
        let template = text(key, language: lang)
        return String(format: template, locale: Locale(identifier: lang.localeIdentifier), arguments: arguments)
    }

    private static func englishText(_ key: AppTextKey) -> String {
        switch key {
        case .alertWriteTitle:
            return "Confirm metadata write?"
        case .buttonCancel:
            return "Cancel"
        case .buttonConfirmWrite:
            return "Confirm Write"
        case .appTitle:
            return "PDF Book/Paper Metadata Assistant"
        case .appSubtitle:
            return "4-step flow: select PDF -> online lookup & merge -> confirm write -> standard rename"
        case .chipPDFFiles:
            return "PDF Files"
        case .chipCurrentStatus:
            return "Current Status"
        case .chipVersion:
            return "Version"
        case .chipLanguage:
            return "Language"
        case .flowTitle:
            return "Workflow Steps"
        case .stepOne:
            return "Select PDF"
        case .stepTwo:
            return "Lookup + Merge"
        case .stepThree:
            return "Confirm Dublin Core"
        case .stepFour:
            return "Ask & Rename"
        case .cardOneTitle:
            return "1) Select PDF"
        case .fieldSelectedPath:
            return "Selected Path"
        case .fieldSelectedPathPlaceholder:
            return "Select a PDF file or folder"
        case .buttonChoose:
            return "Choose"
        case .buttonLoadPDF:
            return "Load PDF"
        case .folderScanHint:
            return "If a folder is selected, all PDF files inside it are scanned recursively."
        case .loadedPDFList:
            return "Loaded PDF List"
        case .noPDFLoaded:
            return "No PDF loaded."
        case .cardTwoTitle:
            return "2) Online Lookup + Merge"
        case .hintFileName:
            return "Filename hint: %@"
        case .hintExtractedTitle:
            return "Extracted title hint: %@"
        case .hintISBN:
            return "Detected ISBN: %@"
        case .hintDOI:
            return "Detected DOI: %@"
        case .hintSnippet:
            return "Content snippet: %@"
        case .sourceOpenLibrary:
            return "Open Library"
        case .sourceGoogleBooks:
            return "Google Books"
        case .sourceDouban:
            return "Douban Web Search"
        case .sourceLOC:
            return "Library of Congress"
        case .buttonSearchMetadata:
            return "Search Metadata Online"
        case .buttonSearching:
            return "Searching..."
        case .searchStrategy:
            return "Strategy: parallel sources -> ISBN/DOI/title+author dedupe -> field merge -> confidence rank"
        case .noCandidates:
            return "No candidate metadata yet. Run online search first."
        case .loadAndSelectFirst:
            return "Please load and select a PDF in Step 1 first."
        case .cardThreeTitle:
            return "3) Confirm Dublin Core Write"
        case .selectedCandidate:
            return "Selected candidate: %@"
        case .sourceConfidence:
            return "Source: %@ | Confidence: %d%%"
        case .noSelectedCandidate:
            return "No metadata candidate selected. Complete Step 2 first."
        case .dublinFieldsTitle:
            return "Dublin Core fields to write (selectable)"
        case .fieldValuePlaceholder:
            return "Field value"
        case .fieldCurrentValue:
            return "Current value: %@"
        case .selectedFieldsCount:
            return "%d fields selected"
        case .buttonConfirmWriteDublin:
            return "Confirm Write Dublin Core Metadata"
        case .editableHint:
            return "Values can be edited manually; write will use edited values."
        case .cardFourTitle:
            return "4) Ask and Rename"
        case .suggestedFileName:
            return "Suggested name: %@"
        case .renameRule:
            return "Rule: title_author_publisher_year_language.pdf"
        case .renameRuleNote:
            return "Spaces inside each field are replaced with '.', while fields remain separated by '_'."
        case .buttonRename:
            return "Rename with Standard Rule"
        case .buttonSkipRename:
            return "Skip Rename"
        case .noRenamePrompt:
            return "No file is waiting for rename confirmation."
        case .executionLog:
            return "Execution Log"
        case .noLogs:
            return "No logs yet."
        case .contentHint:
            return "Content hint: %@"
        case .chipLanguageCode:
            return "Language: %@"
        case .chipValidated:
            return "Validated: %@"
        case .stageNotStarted:
            return "Not Started"
        case .stageLoaded:
            return "Loaded"
        case .stageSearched:
            return "Searched"
        case .stageWritten:
            return "Written"
        case .stageRenamed:
            return "Renamed"
        case .stageRenameSkipped:
            return "Rename Skipped"
        case .stageFailed:
            return "Error"
        case .publicationBook:
            return "Book"
        case .publicationPaper:
            return "Paper"
        case .publicationUnknown:
            return "Unknown"
        case .unknownAuthor:
            return "Unknown Author"
        case .statusReady:
            return "Ready"
        case .statusLanguageChanged:
            return "Language switched to %@"
        case .statusLoadedCount:
            return "Loaded %d PDF(s)"
        case .statusLoadFailed:
            return "Load failed: %@"
        case .statusSelectPDFFirst:
            return "Please select a PDF first"
        case .statusSearching:
            return "Searching online: %@"
        case .statusNoMatch:
            return "No matching metadata found"
        case .statusNoMetadataFound:
            return "No usable metadata found, try refining the file name and retry."
        case .statusSearchComplete:
            return "Search completed, found %d candidate metadata entries"
        case .statusSelectCandidate:
            return "Please select one metadata candidate first"
        case .statusSelectAtLeastOneField:
            return "Please select at least one Dublin Core field"
        case .statusWritePreview:
            return "The following Dublin Core fields will be written:\n%@\n\nContinue?"
        case .statusWriteFailedMissingItem:
            return "Write failed: pending item not found"
        case .statusWriteFailedNoFields:
            return "Write failed: no Dublin Core field selected"
        case .statusWriteSuccess:
            return "Dublin Core metadata written: %@"
        case .statusWriteFailed:
            return "Metadata write failed: %@"
        case .statusRenameMissingContext:
            return "Cannot rename: missing context"
        case .statusRenameSuccess:
            return "Rename succeeded: %@ -> %@"
        case .statusRenameFailed:
            return "Rename failed: %@"
        case .statusRenameSkipped:
            return "Rename skipped: %@"
        case .errorInvalidDirectory:
            return "Directory does not exist or is not accessible."
        case .errorInvalidFile:
            return "Please choose a PDF file or a folder containing PDFs."
        case .errorInvalidInput:
            return "Invalid input: %@"
        case .errorReadFailure:
            return "Read failed: %@"
        case .errorWriteFailure:
            return "Write failed: %@"
        case .errorMoveFailure:
            return "Move failed: %@ -> %@"
        case .errorNetworkFailure:
            return "Network request failed: %@"
        }
    }

    private static func chineseText(_ key: AppTextKey) -> String {
        switch key {
        case .alertWriteTitle:
            return "确认写入元数据？"
        case .buttonCancel:
            return "取消"
        case .buttonConfirmWrite:
            return "确认写入"
        case .appTitle:
            return "PDF 书籍/文献元数据助手"
        case .appSubtitle:
            return "按 4 步流程处理：选择 PDF -> 联网检索与字段合并 -> 确认写入 -> 标准重命名"
        case .chipPDFFiles:
            return "PDF 文件"
        case .chipCurrentStatus:
            return "当前状态"
        case .chipVersion:
            return "版本"
        case .chipLanguage:
            return "语言"
        case .flowTitle:
            return "流程步骤"
        case .stepOne:
            return "选择 PDF"
        case .stepTwo:
            return "联网检索+字段合并"
        case .stepThree:
            return "确认写入 Dublin Core"
        case .stepFour:
            return "询问并重命名"
        case .cardOneTitle:
            return "1) 选择 PDF"
        case .fieldSelectedPath:
            return "已选路径"
        case .fieldSelectedPathPlaceholder:
            return "请选择 PDF 文件或文件夹"
        case .buttonChoose:
            return "选择"
        case .buttonLoadPDF:
            return "加载 PDF"
        case .folderScanHint:
            return "如果选择的是文件夹，程序会递归扫描其中所有 PDF。"
        case .loadedPDFList:
            return "已加载 PDF 列表"
        case .noPDFLoaded:
            return "尚未加载 PDF"
        case .cardTwoTitle:
            return "2) 联网检索+字段合并"
        case .hintFileName:
            return "文件名提示：%@"
        case .hintExtractedTitle:
            return "内容标题提示：%@"
        case .hintISBN:
            return "检测到 ISBN：%@"
        case .hintDOI:
            return "检测到 DOI：%@"
        case .hintSnippet:
            return "内容片段：%@"
        case .sourceOpenLibrary:
            return "Open Library"
        case .sourceGoogleBooks:
            return "Google Books"
        case .sourceDouban:
            return "豆瓣网页搜索"
        case .sourceLOC:
            return "Library of Congress"
        case .buttonSearchMetadata:
            return "联网搜索元数据"
        case .buttonSearching:
            return "正在搜索..."
        case .searchStrategy:
            return "执行策略：多源并行 -> ISBN/DOI/标题作者去重 -> 字段合并 -> 置信度排序"
        case .noCandidates:
            return "还没有候选元数据，请先执行联网搜索。"
        case .loadAndSelectFirst:
            return "请先在第 1 步加载并选择一个 PDF。"
        case .cardThreeTitle:
            return "3) 确认写入 Dublin Core"
        case .selectedCandidate:
            return "当前选中候选：%@"
        case .sourceConfidence:
            return "来源：%@ | 置信度：%d%%"
        case .noSelectedCandidate:
            return "尚未选中候选元数据。请先完成第 2 步搜索并选择候选。"
        case .dublinFieldsTitle:
            return "Dublin Core 写入字段（可选择）"
        case .fieldValuePlaceholder:
            return "字段值"
        case .fieldCurrentValue:
            return "当前值：%@"
        case .selectedFieldsCount:
            return "已选 %d 个字段"
        case .buttonConfirmWriteDublin:
            return "确认写入 Dublin Core 元数据"
        case .editableHint:
            return "字段值可手动编辑；确认写入时将使用编辑后的值。"
        case .cardFourTitle:
            return "4) 询问并重命名"
        case .suggestedFileName:
            return "建议命名：%@"
        case .renameRule:
            return "规则：书名_作者_出版社_出版年_语言.pdf"
        case .renameRuleNote:
            return "字段内空格会替换为 .，字段之间仍使用 _ 分隔。"
        case .buttonRename:
            return "按标准规则重命名"
        case .buttonSkipRename:
            return "暂不重命名"
        case .noRenamePrompt:
            return "当前没有待确认重命名的文件。"
        case .executionLog:
            return "执行日志"
        case .noLogs:
            return "暂无日志"
        case .contentHint:
            return "内容提示：%@"
        case .chipLanguageCode:
            return "语言: %@"
        case .chipValidated:
            return "校验: %@"
        case .stageNotStarted:
            return "未开始"
        case .stageLoaded:
            return "已加载"
        case .stageSearched:
            return "已检索"
        case .stageWritten:
            return "已写入"
        case .stageRenamed:
            return "已重命名"
        case .stageRenameSkipped:
            return "已跳过重命名"
        case .stageFailed:
            return "错误"
        case .publicationBook:
            return "书籍"
        case .publicationPaper:
            return "文献"
        case .publicationUnknown:
            return "未知"
        case .unknownAuthor:
            return "未知作者"
        case .statusReady:
            return "准备就绪"
        case .statusLanguageChanged:
            return "语言已切换为 %@"
        case .statusLoadedCount:
            return "已加载 %d 个 PDF"
        case .statusLoadFailed:
            return "加载失败: %@"
        case .statusSelectPDFFirst:
            return "请先选择一个 PDF"
        case .statusSearching:
            return "正在联网检索: %@"
        case .statusNoMatch:
            return "未找到匹配元数据"
        case .statusNoMetadataFound:
            return "未找到可用元数据，建议调整文件名后重试"
        case .statusSearchComplete:
            return "检索完成，找到 %d 条候选元数据"
        case .statusSelectCandidate:
            return "请先选择一条候选元数据"
        case .statusSelectAtLeastOneField:
            return "请至少选择一个 Dublin Core 写入字段"
        case .statusWritePreview:
            return "将按 Dublin Core 写入以下字段：\n%@\n\n确认继续？"
        case .statusWriteFailedMissingItem:
            return "写入失败: 未找到待写入项"
        case .statusWriteFailedNoFields:
            return "写入失败: 没有选中任何 Dublin Core 字段"
        case .statusWriteSuccess:
            return "Dublin Core 元数据写入成功: %@"
        case .statusWriteFailed:
            return "元数据写入失败: %@"
        case .statusRenameMissingContext:
            return "无法执行重命名: 缺少上下文"
        case .statusRenameSuccess:
            return "重命名成功: %@ -> %@"
        case .statusRenameFailed:
            return "重命名失败: %@"
        case .statusRenameSkipped:
            return "已跳过重命名: %@"
        case .errorInvalidDirectory:
            return "目录不存在或不可访问。"
        case .errorInvalidFile:
            return "请选择 PDF 文件或包含 PDF 的目录。"
        case .errorInvalidInput:
            return "输入无效: %@"
        case .errorReadFailure:
            return "读取失败: %@"
        case .errorWriteFailure:
            return "写入失败: %@"
        case .errorMoveFailure:
            return "移动失败: %@ -> %@"
        case .errorNetworkFailure:
            return "网络请求失败: %@"
        }
    }

    private static func spanishText(_ key: AppTextKey) -> String? {
        switch key {
        case .alertWriteTitle: return "¿Confirmar escritura de metadatos?"
        case .buttonCancel: return "Cancelar"
        case .buttonConfirmWrite: return "Confirmar escritura"
        case .chipPDFFiles: return "Archivos PDF"
        case .chipCurrentStatus: return "Estado actual"
        case .chipVersion: return "Versión"
        case .chipLanguage: return "Idioma"
        case .flowTitle: return "Pasos del flujo"
        case .stepOne: return "Seleccionar PDF"
        case .stepTwo: return "Buscar y combinar"
        case .stepThree: return "Confirmar Dublin Core"
        case .stepFour: return "Preguntar y renombrar"
        case .cardOneTitle: return "1) Seleccionar PDF"
        case .buttonChoose: return "Elegir"
        case .buttonLoadPDF: return "Cargar PDF"
        case .cardTwoTitle: return "2) Búsqueda en línea + combinación"
        case .buttonSearchMetadata: return "Buscar metadatos en línea"
        case .buttonSearching: return "Buscando..."
        case .cardThreeTitle: return "3) Confirmar escritura Dublin Core"
        case .buttonConfirmWriteDublin: return "Confirmar escritura Dublin Core"
        case .cardFourTitle: return "4) Preguntar y renombrar"
        case .buttonRename: return "Renombrar con regla estándar"
        case .buttonSkipRename: return "Omitir renombrado"
        case .executionLog: return "Registro de ejecución"
        case .noLogs: return "Sin registros."
        case .stageNotStarted: return "Sin iniciar"
        case .stageLoaded: return "Cargado"
        case .stageSearched: return "Buscado"
        case .stageWritten: return "Escrito"
        case .stageRenamed: return "Renombrado"
        case .stageRenameSkipped: return "Renombrado omitido"
        case .stageFailed: return "Error"
        case .publicationBook: return "Libro"
        case .publicationPaper: return "Artículo"
        case .publicationUnknown: return "Desconocido"
        case .statusReady: return "Listo"
        default: return nil
        }
    }

    private static func hindiText(_ key: AppTextKey) -> String? {
        switch key {
        case .alertWriteTitle: return "मेटाडेटा लिखना पुष्टि करें?"
        case .buttonCancel: return "रद्द करें"
        case .buttonConfirmWrite: return "लिखना पुष्टि करें"
        case .chipPDFFiles: return "PDF फ़ाइलें"
        case .chipCurrentStatus: return "वर्तमान स्थिति"
        case .chipVersion: return "संस्करण"
        case .chipLanguage: return "भाषा"
        case .flowTitle: return "प्रक्रिया चरण"
        case .stepOne: return "PDF चुनें"
        case .stepTwo: return "खोजें और मर्ज करें"
        case .stepThree: return "Dublin Core पुष्टि"
        case .stepFour: return "पूछें और नाम बदलें"
        case .cardOneTitle: return "1) PDF चुनें"
        case .buttonChoose: return "चुनें"
        case .buttonLoadPDF: return "PDF लोड करें"
        case .cardTwoTitle: return "2) ऑनलाइन खोज + मर्ज"
        case .buttonSearchMetadata: return "ऑनलाइन मेटाडेटा खोजें"
        case .buttonSearching: return "खोज रहे हैं..."
        case .cardThreeTitle: return "3) Dublin Core लिखने की पुष्टि"
        case .buttonConfirmWriteDublin: return "Dublin Core लिखना पुष्टि करें"
        case .cardFourTitle: return "4) पूछें और नाम बदलें"
        case .buttonRename: return "मानक नियम से नाम बदलें"
        case .buttonSkipRename: return "नाम बदलना छोड़ें"
        case .executionLog: return "निष्पादन लॉग"
        case .noLogs: return "कोई लॉग नहीं।"
        case .stageNotStarted: return "शुरू नहीं"
        case .stageLoaded: return "लोड हो गया"
        case .stageSearched: return "खोजा गया"
        case .stageWritten: return "लिखा गया"
        case .stageRenamed: return "नाम बदला गया"
        case .stageRenameSkipped: return "नाम बदलना छोड़ा गया"
        case .stageFailed: return "त्रुटि"
        case .publicationBook: return "पुस्तक"
        case .publicationPaper: return "लेख"
        case .publicationUnknown: return "अज्ञात"
        case .statusReady: return "तैयार"
        default: return nil
        }
    }

    private static func arabicText(_ key: AppTextKey) -> String? {
        switch key {
        case .alertWriteTitle: return "تأكيد كتابة البيانات الوصفية؟"
        case .buttonCancel: return "إلغاء"
        case .buttonConfirmWrite: return "تأكيد الكتابة"
        case .chipPDFFiles: return "ملفات PDF"
        case .chipCurrentStatus: return "الحالة الحالية"
        case .chipVersion: return "الإصدار"
        case .chipLanguage: return "اللغة"
        case .flowTitle: return "خطوات العمل"
        case .stepOne: return "اختيار PDF"
        case .stepTwo: return "بحث ودمج"
        case .stepThree: return "تأكيد Dublin Core"
        case .stepFour: return "اسأل وأعد التسمية"
        case .cardOneTitle: return "1) اختيار PDF"
        case .buttonChoose: return "اختيار"
        case .buttonLoadPDF: return "تحميل PDF"
        case .cardTwoTitle: return "2) بحث عبر الإنترنت + دمج"
        case .buttonSearchMetadata: return "بحث البيانات الوصفية عبر الإنترنت"
        case .buttonSearching: return "جارٍ البحث..."
        case .cardThreeTitle: return "3) تأكيد كتابة Dublin Core"
        case .buttonConfirmWriteDublin: return "تأكيد كتابة Dublin Core"
        case .cardFourTitle: return "4) اسأل وأعد التسمية"
        case .buttonRename: return "إعادة تسمية بالقاعدة القياسية"
        case .buttonSkipRename: return "تخطي إعادة التسمية"
        case .executionLog: return "سجل التنفيذ"
        case .noLogs: return "لا توجد سجلات."
        case .stageNotStarted: return "لم يبدأ"
        case .stageLoaded: return "تم التحميل"
        case .stageSearched: return "تم البحث"
        case .stageWritten: return "تمت الكتابة"
        case .stageRenamed: return "تمت إعادة التسمية"
        case .stageRenameSkipped: return "تم تخطي إعادة التسمية"
        case .stageFailed: return "خطأ"
        case .publicationBook: return "كتاب"
        case .publicationPaper: return "بحث"
        case .publicationUnknown: return "غير معروف"
        case .statusReady: return "جاهز"
        default: return nil
        }
    }

    private static func frenchText(_ key: AppTextKey) -> String? {
        switch key {
        case .alertWriteTitle: return "Confirmer l'écriture des métadonnées ?"
        case .buttonCancel: return "Annuler"
        case .buttonConfirmWrite: return "Confirmer l'écriture"
        case .chipPDFFiles: return "Fichiers PDF"
        case .chipCurrentStatus: return "État actuel"
        case .chipVersion: return "Version"
        case .chipLanguage: return "Langue"
        case .flowTitle: return "Étapes du flux"
        case .stepOne: return "Sélectionner PDF"
        case .stepTwo: return "Recherche + fusion"
        case .stepThree: return "Confirmer Dublin Core"
        case .stepFour: return "Demander et renommer"
        case .cardOneTitle: return "1) Sélectionner PDF"
        case .buttonChoose: return "Choisir"
        case .buttonLoadPDF: return "Charger PDF"
        case .cardTwoTitle: return "2) Recherche en ligne + fusion"
        case .buttonSearchMetadata: return "Rechercher les métadonnées"
        case .buttonSearching: return "Recherche..."
        case .cardThreeTitle: return "3) Confirmer l'écriture Dublin Core"
        case .buttonConfirmWriteDublin: return "Confirmer l'écriture Dublin Core"
        case .cardFourTitle: return "4) Demander et renommer"
        case .buttonRename: return "Renommer selon la règle"
        case .buttonSkipRename: return "Ignorer le renommage"
        case .executionLog: return "Journal d'exécution"
        case .noLogs: return "Aucun journal."
        case .stageNotStarted: return "Non démarré"
        case .stageLoaded: return "Chargé"
        case .stageSearched: return "Recherché"
        case .stageWritten: return "Écrit"
        case .stageRenamed: return "Renommé"
        case .stageRenameSkipped: return "Renommage ignoré"
        case .stageFailed: return "Erreur"
        case .publicationBook: return "Livre"
        case .publicationPaper: return "Article"
        case .publicationUnknown: return "Inconnu"
        case .statusReady: return "Prêt"
        default: return nil
        }
    }

    private static func portugueseText(_ key: AppTextKey) -> String? {
        switch key {
        case .alertWriteTitle: return "Confirmar gravação dos metadados?"
        case .buttonCancel: return "Cancelar"
        case .buttonConfirmWrite: return "Confirmar gravação"
        case .chipPDFFiles: return "Arquivos PDF"
        case .chipCurrentStatus: return "Status atual"
        case .chipVersion: return "Versão"
        case .chipLanguage: return "Idioma"
        case .flowTitle: return "Etapas do fluxo"
        case .stepOne: return "Selecionar PDF"
        case .stepTwo: return "Buscar e mesclar"
        case .stepThree: return "Confirmar Dublin Core"
        case .stepFour: return "Perguntar e renomear"
        case .cardOneTitle: return "1) Selecionar PDF"
        case .buttonChoose: return "Escolher"
        case .buttonLoadPDF: return "Carregar PDF"
        case .cardTwoTitle: return "2) Busca online + mesclagem"
        case .buttonSearchMetadata: return "Buscar metadados online"
        case .buttonSearching: return "Buscando..."
        case .cardThreeTitle: return "3) Confirmar gravação Dublin Core"
        case .buttonConfirmWriteDublin: return "Confirmar gravação Dublin Core"
        case .cardFourTitle: return "4) Perguntar e renomear"
        case .buttonRename: return "Renomear com regra padrão"
        case .buttonSkipRename: return "Pular renomeação"
        case .executionLog: return "Log de execução"
        case .noLogs: return "Sem logs."
        case .stageNotStarted: return "Não iniciado"
        case .stageLoaded: return "Carregado"
        case .stageSearched: return "Pesquisado"
        case .stageWritten: return "Gravado"
        case .stageRenamed: return "Renomeado"
        case .stageRenameSkipped: return "Renomeação ignorada"
        case .stageFailed: return "Erro"
        case .publicationBook: return "Livro"
        case .publicationPaper: return "Artigo"
        case .publicationUnknown: return "Desconhecido"
        case .statusReady: return "Pronto"
        default: return nil
        }
    }

    private static func russianText(_ key: AppTextKey) -> String? {
        switch key {
        case .alertWriteTitle: return "Подтвердить запись метаданных?"
        case .buttonCancel: return "Отмена"
        case .buttonConfirmWrite: return "Подтвердить запись"
        case .chipPDFFiles: return "PDF файлы"
        case .chipCurrentStatus: return "Текущий статус"
        case .chipVersion: return "Версия"
        case .chipLanguage: return "Язык"
        case .flowTitle: return "Шаги процесса"
        case .stepOne: return "Выбрать PDF"
        case .stepTwo: return "Поиск и объединение"
        case .stepThree: return "Подтвердить Dublin Core"
        case .stepFour: return "Спросить и переименовать"
        case .cardOneTitle: return "1) Выбрать PDF"
        case .buttonChoose: return "Выбрать"
        case .buttonLoadPDF: return "Загрузить PDF"
        case .cardTwoTitle: return "2) Онлайн-поиск + объединение"
        case .buttonSearchMetadata: return "Искать метаданные онлайн"
        case .buttonSearching: return "Поиск..."
        case .cardThreeTitle: return "3) Подтвердить запись Dublin Core"
        case .buttonConfirmWriteDublin: return "Подтвердить запись Dublin Core"
        case .cardFourTitle: return "4) Спросить и переименовать"
        case .buttonRename: return "Переименовать по правилу"
        case .buttonSkipRename: return "Пропустить переименование"
        case .executionLog: return "Журнал выполнения"
        case .noLogs: return "Пока нет журналов."
        case .stageNotStarted: return "Не начато"
        case .stageLoaded: return "Загружено"
        case .stageSearched: return "Найдено"
        case .stageWritten: return "Записано"
        case .stageRenamed: return "Переименовано"
        case .stageRenameSkipped: return "Переименование пропущено"
        case .stageFailed: return "Ошибка"
        case .publicationBook: return "Книга"
        case .publicationPaper: return "Статья"
        case .publicationUnknown: return "Неизвестно"
        case .statusReady: return "Готово"
        default: return nil
        }
    }

    private static func japaneseText(_ key: AppTextKey) -> String? {
        switch key {
        case .alertWriteTitle: return "メタデータ書き込みを確認しますか？"
        case .buttonCancel: return "キャンセル"
        case .buttonConfirmWrite: return "書き込み確認"
        case .chipPDFFiles: return "PDFファイル"
        case .chipCurrentStatus: return "現在の状態"
        case .chipVersion: return "バージョン"
        case .chipLanguage: return "言語"
        case .flowTitle: return "ワークフロー"
        case .stepOne: return "PDFを選択"
        case .stepTwo: return "検索と統合"
        case .stepThree: return "Dublin Core確認"
        case .stepFour: return "確認してリネーム"
        case .cardOneTitle: return "1) PDFを選択"
        case .buttonChoose: return "選択"
        case .buttonLoadPDF: return "PDFを読み込む"
        case .cardTwoTitle: return "2) オンライン検索 + 統合"
        case .buttonSearchMetadata: return "オンラインでメタデータ検索"
        case .buttonSearching: return "検索中..."
        case .cardThreeTitle: return "3) Dublin Core書き込み確認"
        case .buttonConfirmWriteDublin: return "Dublin Core書き込み確認"
        case .cardFourTitle: return "4) 確認してリネーム"
        case .buttonRename: return "標準ルールでリネーム"
        case .buttonSkipRename: return "リネームしない"
        case .executionLog: return "実行ログ"
        case .noLogs: return "ログはありません。"
        case .stageNotStarted: return "未開始"
        case .stageLoaded: return "読み込み済み"
        case .stageSearched: return "検索済み"
        case .stageWritten: return "書き込み済み"
        case .stageRenamed: return "リネーム済み"
        case .stageRenameSkipped: return "リネームをスキップ"
        case .stageFailed: return "エラー"
        case .publicationBook: return "書籍"
        case .publicationPaper: return "論文"
        case .publicationUnknown: return "不明"
        case .statusReady: return "準備完了"
        default: return nil
        }
    }

    private static func germanText(_ key: AppTextKey) -> String? {
        switch key {
        case .alertWriteTitle: return "Schreiben der Metadaten bestätigen?"
        case .buttonCancel: return "Abbrechen"
        case .buttonConfirmWrite: return "Schreiben bestätigen"
        case .chipPDFFiles: return "PDF-Dateien"
        case .chipCurrentStatus: return "Aktueller Status"
        case .chipVersion: return "Version"
        case .chipLanguage: return "Sprache"
        case .flowTitle: return "Ablaufschritte"
        case .stepOne: return "PDF wählen"
        case .stepTwo: return "Suchen und zusammenführen"
        case .stepThree: return "Dublin Core bestätigen"
        case .stepFour: return "Fragen und umbenennen"
        case .cardOneTitle: return "1) PDF wählen"
        case .buttonChoose: return "Wählen"
        case .buttonLoadPDF: return "PDF laden"
        case .cardTwoTitle: return "2) Online-Suche + Zusammenführung"
        case .buttonSearchMetadata: return "Metadaten online suchen"
        case .buttonSearching: return "Suche läuft..."
        case .cardThreeTitle: return "3) Dublin Core schreiben bestätigen"
        case .buttonConfirmWriteDublin: return "Dublin Core schreiben bestätigen"
        case .cardFourTitle: return "4) Fragen und umbenennen"
        case .buttonRename: return "Mit Standardregel umbenennen"
        case .buttonSkipRename: return "Umbenennen überspringen"
        case .executionLog: return "Ausführungsprotokoll"
        case .noLogs: return "Keine Protokolle."
        case .stageNotStarted: return "Nicht gestartet"
        case .stageLoaded: return "Geladen"
        case .stageSearched: return "Gesucht"
        case .stageWritten: return "Geschrieben"
        case .stageRenamed: return "Umbenannt"
        case .stageRenameSkipped: return "Umbenennen übersprungen"
        case .stageFailed: return "Fehler"
        case .publicationBook: return "Buch"
        case .publicationPaper: return "Paper"
        case .publicationUnknown: return "Unbekannt"
        case .statusReady: return "Bereit"
        default: return nil
        }
    }
}
