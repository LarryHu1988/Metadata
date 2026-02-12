import SwiftUI
import AppKit

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()

    var body: some View {
        ZStack {
            background

            ScrollView {
                VStack(spacing: 14) {
                    headerCard
                    stepCard
                    sourceCard
                    pdfListCard
                    metadataSearchCard
                    renameCard
                    logCard
                }
                .frame(maxWidth: 1160)
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
        }
        .alert("确认写入元数据？", isPresented: $viewModel.showWriteConfirmation) {
            Button("取消", role: .cancel) {
                viewModel.cancelWriteConfirmation()
            }
            Button("确认写入") {
                viewModel.performWriteConfirmed()
            }
        } message: {
            Text(viewModel.pendingWriteSummary)
        }
    }

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.11, green: 0.17, blue: 0.42),
                    Color(red: 0.14, green: 0.22, blue: 0.52),
                    Color(red: 0.10, green: 0.27, blue: 0.49)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.10))
                .frame(width: 500, height: 500)
                .blur(radius: 30)
                .offset(x: -420, y: -300)

            Circle()
                .fill(Color.white.opacity(0.07))
                .frame(width: 420, height: 420)
                .blur(radius: 36)
                .offset(x: 420, y: 300)
        }
    }

    private var headerCard: some View {
        GlassCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Label("PDF 书籍/文献元数据助手", systemImage: "books.vertical.fill")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                    Text("按 4 步流程处理：选择 PDF -> 联网检索 -> 确认写入 -> 标准重命名")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    CountChip(title: "PDF 文件", value: "\(viewModel.items.count)")
                    CountChip(title: "当前状态", value: viewModel.currentStageName)
                    CountChip(title: "版本", value: appVersionText)
                }
            }
        }
    }

    private var appVersionText: String {
        let short = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "dev"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? short
        return "\(short)-\(build)"
    }

    private var stepCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                CardTitle("流程步骤")
                HStack(spacing: 8) {
                    StepPill(index: 1, title: "选择 PDF", activeStep: viewModel.currentStep)
                    StepPill(index: 2, title: "联网检索元数据", activeStep: viewModel.currentStep)
                    StepPill(index: 3, title: "确认写入元数据", activeStep: viewModel.currentStep)
                    StepPill(index: 4, title: "询问并重命名", activeStep: viewModel.currentStep)
                }
            }
        }
    }

    private var sourceCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                CardTitle("1) 选择文件或文件夹（仅处理 PDF）")

                HStack(spacing: 10) {
                    FieldBlock(title: "已选路径", placeholder: "请选择 PDF 文件或文件夹", text: $viewModel.sourcePath)
                    Button("选择") { viewModel.pickSource() }
                        .buttonStyle(SecondaryButton())
                    Button("加载 PDF") { viewModel.loadPDFsFromSource() }
                        .buttonStyle(PrimaryButton())
                }

                Text("如果选择的是文件夹，程序会递归扫描其中所有 PDF。")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var pdfListCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                CardTitle("已加载 PDF 列表")

                if viewModel.items.isEmpty {
                    Text("尚未加载 PDF")
                        .foregroundStyle(.secondary)
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.items) { item in
                            PDFItemRow(
                                item: item,
                                isSelected: viewModel.selectedItemID == item.id,
                                onTap: { viewModel.selectItem(item.id) }
                            )
                        }
                    }
                }
            }
        }
    }

    private var metadataSearchCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                CardTitle("2) 根据文件名或内容联网搜索元数据")

                if let item = viewModel.selectedItem {
                    HStack(alignment: .top, spacing: 10) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("文件名提示：\(item.hint.fileNameTitle)")
                            Text("内容标题提示：\(item.hint.extractedTitle)")
                            if let isbn = item.hint.isbn {
                                Text("检测到 ISBN：\(isbn)")
                            }
                            if let doi = item.hint.doi {
                                Text("检测到 DOI：\(doi)")
                            }
                            if !item.hint.snippet.isEmpty {
                                Text("内容片段：\(item.hint.snippet)")
                                    .lineLimit(2)
                            }
                        }
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)

                        Spacer()

                        VStack(alignment: .leading, spacing: 6) {
                            Toggle("Open Library（主）", isOn: $viewModel.sourceOptions.useOpenLibrary)
                                .toggleStyle(.switch)
                            Toggle("Google Books（补充）", isOn: $viewModel.sourceOptions.useGoogleBooks)
                                .toggleStyle(.switch)
                            Toggle("LoC（校验）", isOn: $viewModel.sourceOptions.useLoCValidation)
                                .toggleStyle(.switch)
                            Toggle("WorldCat（校验）", isOn: $viewModel.sourceOptions.useWorldCatValidation)
                                .toggleStyle(.switch)

                            if viewModel.sourceOptions.useWorldCatValidation {
                                FieldBlock(title: "WorldCat API Key", placeholder: "请输入 OCLC API Key", text: $viewModel.sourceOptions.worldCatAPIKey)
                                    .frame(width: 320)
                                SecureFieldBlock(title: "WorldCat API Secret", placeholder: "请输入 OCLC API Secret", text: $viewModel.sourceOptions.worldCatAPISecret)
                                    .frame(width: 320)
                                FieldBlock(title: "Scope", placeholder: "wcapi", text: $viewModel.sourceOptions.worldCatScope)
                                    .frame(width: 320)

                                if !viewModel.hasWorldCatCredentials {
                                    Text("未填写 API Key/Secret 时会跳过 WorldCat 官方校验。")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundStyle(.orange)
                                }
                            }
                        }
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }

                    HStack(spacing: 8) {
                        Button(viewModel.isSearching ? "正在搜索..." : "联网搜索元数据") {
                            viewModel.searchMetadataForSelectedItem()
                        }
                        .buttonStyle(PrimaryButton())
                        .disabled(viewModel.isSearching)

                        Text("执行顺序：ISBN -> Open Library -> Google Books -> LoC/WorldCat 校验")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundStyle(.secondary)
                    }

                    if item.candidates.isEmpty {
                        Text("还没有候选元数据，请先执行联网搜索。")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundStyle(.secondary)
                    } else {
                        VStack(alignment: .leading, spacing: 7) {
                            ForEach(item.candidates) { candidate in
                                CandidateRow(
                                    candidate: candidate,
                                    selected: item.selectedCandidateID == candidate.id,
                                    onTap: {
                                        viewModel.chooseCandidate(candidate.id, for: item.id)
                                    }
                                )
                            }
                        }

                        HStack(spacing: 8) {
                            Button("3) 确认写入元数据") {
                                viewModel.askWriteConfirmationForSelectedItem()
                            }
                            .buttonStyle(PrimaryButton())
                            .disabled(item.selectedCandidateID == nil)

                            Text("写入前会弹窗确认。")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    Text("请先在上方列表中选择一个 PDF。")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var renameCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                CardTitle("4) 写入后询问是否按标准规则重命名")

                if let prompt = viewModel.renamePrompt {
                    Text("建议命名：\(prompt.suggestedFileName)")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))

                    Text("规则：书名_作者_出版社_出版年_语言.pdf")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        Button("按标准规则重命名") {
                            viewModel.confirmRenameForPrompt()
                        }
                        .buttonStyle(PrimaryButton())

                        Button("暂不重命名") {
                            viewModel.skipRenameForPrompt()
                        }
                        .buttonStyle(SecondaryButton())
                    }
                } else {
                    Text("当前没有待确认重命名的文件。")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var logCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                CardTitle("执行日志")
                Text(viewModel.status)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 0.11, green: 0.15, blue: 0.35))

                if viewModel.logs.isEmpty {
                    Text("暂无日志")
                        .foregroundStyle(.secondary)
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(viewModel.logs.suffix(120).enumerated()), id: \.offset) { _, line in
                            Text(line)
                                .font(.system(size: 11, weight: .regular, design: .monospaced))
                                .foregroundStyle(Color.white.opacity(0.9))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.black.opacity(0.84))
                    )
                }
            }
        }
    }
}

struct PDFItemRow: View {
    let item: PDFWorkItem
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.blue : Color.gray)
                    .font(.system(size: 15, weight: .semibold))
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(item.url.lastPathComponent)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                        Spacer()
                        StageBadge(stage: item.stage)
                    }

                    Text(item.url.path)
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    Text("内容提示：\(item.hint.extractedTitle)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isSelected ? Color.white.opacity(0.90) : Color.white.opacity(0.72))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isSelected ? Color.blue.opacity(0.44) : Color.white.opacity(0.64), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct CandidateRow: View {
    let candidate: BookMetadataCandidate
    let selected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: selected ? "largecircle.fill.circle" : "circle")
                    .foregroundStyle(selected ? Color.blue : Color.gray)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(candidate.primaryTitle)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 0.10, green: 0.13, blue: 0.27))
                        Spacer()
                        Text("\(candidate.confidence)%")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 0.22, green: 0.28, blue: 0.73))
                    }

                    Text("\(candidate.kind.displayName) | \(candidate.authorsText)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)

                    Text("\(candidate.publisher) \(candidate.publishedYear)")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary)

                    HStack(spacing: 6) {
                        if !candidate.isbn.isEmpty {
                            MiniChip(text: "ISBN: \(candidate.isbn)")
                        }
                        if !candidate.language.isEmpty {
                            MiniChip(text: "语言: \(candidate.language)")
                        }
                        if !candidate.validatedBy.isEmpty {
                            MiniChip(text: "校验: \(candidate.validatedBy.joined(separator: "/"))")
                        }
                        MiniChip(text: candidate.source)
                    }
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(selected ? Color.white.opacity(0.92) : Color.white.opacity(0.74))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(selected ? Color.blue.opacity(0.44) : Color.white.opacity(0.64), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct StepPill: View {
    let index: Int
    let title: String
    let activeStep: Int

    var body: some View {
        let active = index <= activeStep

        HStack(spacing: 6) {
            Text("\(index)")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .frame(width: 18, height: 18)
                .background(
                    Circle().fill(active ? Color.white : Color.white.opacity(0.6))
                )
                .foregroundStyle(active ? Color.blue : Color.gray)

            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            Capsule().fill(active ? Color.white.opacity(0.88) : Color.white.opacity(0.55))
        )
    }
}

struct StageBadge: View {
    let stage: PDFWorkflowStage

    var body: some View {
        Text(stage.displayName)
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule().fill(stageColor.opacity(0.18))
            )
            .foregroundStyle(stageColor)
    }

    private var stageColor: Color {
        switch stage {
        case .loaded:
            return Color(red: 0.25, green: 0.37, blue: 0.86)
        case .searched:
            return Color(red: 0.20, green: 0.50, blue: 0.78)
        case .written:
            return Color(red: 0.20, green: 0.60, blue: 0.40)
        case .renamed:
            return Color(red: 0.10, green: 0.58, blue: 0.31)
        case .renameSkipped:
            return Color(red: 0.72, green: 0.49, blue: 0.14)
        case .failed:
            return Color(red: 0.78, green: 0.23, blue: 0.23)
        }
    }
}

struct MiniChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Capsule().fill(Color(red: 0.28, green: 0.31, blue: 0.90).opacity(0.14)))
            .foregroundStyle(Color(red: 0.18, green: 0.22, blue: 0.56))
            .lineLimit(1)
    }
}

struct GlassCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.94))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.52), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.16), radius: 18, x: 0, y: 10)
    }
}

struct CardTitle: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundStyle(Color(red: 0.10, green: 0.12, blue: 0.26))
    }
}

struct CountChip: View {
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.23, green: 0.27, blue: 0.71))
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(Capsule().fill(Color.white.opacity(0.85)))
    }
}

struct FieldBlock: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .background(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(Color.white.opacity(0.92))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke(Color(red: 0.74, green: 0.76, blue: 0.90).opacity(0.70), lineWidth: 1)
                )
        }
    }
}

struct SecureFieldBlock: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)

            SecureField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .background(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(Color.white.opacity(0.92))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke(Color(red: 0.74, green: 0.76, blue: 0.90).opacity(0.70), lineWidth: 1)
                )
        }
    }
}

struct PrimaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.27, green: 0.32, blue: 0.94),
                        Color(red: 0.44, green: 0.29, blue: 0.93)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
            .opacity(configuration.isPressed ? 0.88 : 1)
    }
}

struct SecondaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(Color(red: 0.20, green: 0.25, blue: 0.62))
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(Color.white.opacity(configuration.isPressed ? 0.80 : 0.94))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .stroke(Color(red: 0.62, green: 0.66, blue: 0.90).opacity(0.75), lineWidth: 1)
            )
    }
}

struct RenamePromptState {
    let itemID: UUID
    let suggestedFileName: String
}

@MainActor
final class MainViewModel: ObservableObject {
    @Published var sourcePath: String = NSHomeDirectory()
    @Published var items: [PDFWorkItem] = []
    @Published var selectedItemID: UUID?
    @Published var sourceOptions = MetadataSourceOptions()

    @Published var status: String = "准备就绪"
    @Published var logs: [String] = []

    @Published var isSearching = false

    @Published var showWriteConfirmation = false
    @Published var pendingWriteSummary: String = ""

    private var pendingWriteItemID: UUID?
    @Published var renamePrompt: RenamePromptState?

    private let libraryService = PDFLibraryService()
    private let metadataService = MetadataService()
    private let fetcher = BookMetadataFetcher()
    private let renameService = BookRenameService()

    var selectedItem: PDFWorkItem? {
        guard let selectedItemID,
              let item = items.first(where: { $0.id == selectedItemID })
        else {
            return nil
        }
        return item
    }

    var currentStageName: String {
        selectedItem?.stage.displayName ?? "未开始"
    }

    var hasWorldCatCredentials: Bool {
        let key = sourceOptions.worldCatAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let secret = sourceOptions.worldCatAPISecret.trimmingCharacters(in: .whitespacesAndNewlines)
        return !key.isEmpty && !secret.isEmpty
    }

    var currentStep: Int {
        guard let item = selectedItem else { return 1 }
        switch item.stage {
        case .loaded, .failed:
            return 2
        case .searched:
            return 3
        case .written, .renamed, .renameSkipped:
            return 4
        }
    }

    func pickSource() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = false

        if panel.runModal() == .OK, let path = panel.url?.path {
            sourcePath = path
        }
    }

    func loadPDFsFromSource() {
        let sourceURL = URL(fileURLWithPath: sourcePath)

        do {
            let pdfs = try libraryService.collectPDFs(from: sourceURL)
            items = pdfs.map { url in
                PDFWorkItem(url: url, hint: libraryService.buildHint(for: url))
            }
            selectedItemID = items.first?.id
            renamePrompt = nil
            status = "已加载 \(items.count) 个 PDF"
            appendLog(status)
        } catch {
            status = "加载失败: \(error.localizedDescription)"
            appendLog(status)
        }
    }

    func selectItem(_ id: UUID) {
        selectedItemID = id
    }

    func searchMetadataForSelectedItem() {
        guard let item = selectedItem else {
            status = "请先选择一个 PDF"
            return
        }
        if isSearching {
            return
        }

        isSearching = true
        status = "正在联网检索: \(item.url.lastPathComponent)"
        appendLog(status)

        if sourceOptions.useWorldCatValidation, !hasWorldCatCredentials {
            appendLog("未配置 WorldCat API Key/Secret，已跳过 WorldCat 官方 API 校验。")
        }

        let itemID = item.id
        let hint = item.hint
        let options = sourceOptions

        Task {
            let candidates = await fetcher.fetchCandidates(hint: hint, options: options)

            guard let index = self.items.firstIndex(where: { $0.id == itemID }) else {
                self.isSearching = false
                return
            }

            self.items[index].candidates = candidates
            self.items[index].selectedCandidateID = candidates.first?.id
            if candidates.isEmpty {
                self.items[index].stage = .failed
                self.items[index].lastError = "未找到匹配元数据"
                self.status = "未找到可用元数据，建议调整文件名后重试"
            } else {
                self.items[index].stage = .searched
                self.status = "检索完成，找到 \(candidates.count) 条候选元数据"
            }
            self.appendLog(self.status)
            self.isSearching = false
        }
    }

    func chooseCandidate(_ candidateID: UUID, for itemID: UUID) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        items[index].selectedCandidateID = candidateID
    }

    func askWriteConfirmationForSelectedItem() {
        guard let item = selectedItem,
              let candidate = selectedCandidate(for: item)
        else {
            status = "请先选择一条候选元数据"
            return
        }

        pendingWriteItemID = item.id
        pendingWriteSummary = "将写入：\n标题: \(candidate.primaryTitle)\n作者: \(candidate.authorsText)\n出版社: \(candidate.publisher)\n出版年: \(candidate.publishedYear)\n语言: \(candidate.language)\n来源: \(candidate.source)\n校验: \(candidate.validatedBy.joined(separator: "/"))\n\n确认继续？"
        showWriteConfirmation = true
    }

    func cancelWriteConfirmation() {
        pendingWriteItemID = nil
        pendingWriteSummary = ""
    }

    func performWriteConfirmed() {
        guard let itemID = pendingWriteItemID,
              let index = items.firstIndex(where: { $0.id == itemID }),
              let candidate = selectedCandidate(for: items[index])
        else {
            status = "写入失败: 未找到待写入项"
            appendLog(status)
            return
        }

        let url = items[index].url

        let entries: [String: String] = [
            "book.kind": candidate.kind.rawValue,
            "book.title": candidate.title,
            "book.subtitle": candidate.subtitle,
            "book.authors": candidate.authorsText,
            "book.publisher": candidate.publisher,
            "book.publishedYear": candidate.publishedYear,
            "book.language": candidate.language,
            "book.isbn": candidate.isbn,
            "book.doi": candidate.doi,
            "book.source": candidate.source,
            "book.sourceURL": candidate.sourceURL,
            "book.validation": candidate.validatedBy.joined(separator: ",")
        ]

        do {
            try metadataService.writeMetadata(fileURL: url, entries: entries)
            items[index].stage = .written
            status = "元数据写入成功: \(url.lastPathComponent)"
            appendLog(status)

            let suggested = renameService.suggestedFileName(for: candidate, originalExtension: url.pathExtension)
            renamePrompt = RenamePromptState(itemID: itemID, suggestedFileName: suggested)
        } catch {
            items[index].stage = .failed
            items[index].lastError = error.localizedDescription
            status = "元数据写入失败: \(error.localizedDescription)"
            appendLog(status)
        }

        pendingWriteItemID = nil
        pendingWriteSummary = ""
    }

    func confirmRenameForPrompt() {
        guard let prompt = renamePrompt,
              let index = items.firstIndex(where: { $0.id == prompt.itemID }),
              let candidate = selectedCandidate(for: items[index])
        else {
            status = "无法执行重命名: 缺少上下文"
            appendLog(status)
            return
        }

        let oldURL = items[index].url

        do {
            let newURL = try renameService.renameFile(at: oldURL, using: candidate)
            items[index].url = newURL
            items[index].stage = .renamed
            status = "重命名成功: \(oldURL.lastPathComponent) -> \(newURL.lastPathComponent)"
            appendLog(status)
            renamePrompt = nil
        } catch {
            items[index].stage = .failed
            items[index].lastError = error.localizedDescription
            status = "重命名失败: \(error.localizedDescription)"
            appendLog(status)
        }
    }

    func skipRenameForPrompt() {
        guard let prompt = renamePrompt,
              let index = items.firstIndex(where: { $0.id == prompt.itemID })
        else {
            renamePrompt = nil
            return
        }

        items[index].stage = .renameSkipped
        status = "已跳过重命名: \(items[index].url.lastPathComponent)"
        appendLog(status)
        renamePrompt = nil
    }

    private func selectedCandidate(for item: PDFWorkItem) -> BookMetadataCandidate? {
        guard let id = item.selectedCandidateID else { return nil }
        return item.candidates.first(where: { $0.id == id })
    }

    private func appendLog(_ line: String) {
        logs.append("[\(DateFormatter.logTimestamp.string(from: Date()))] \(line)")
    }
}

private extension DateFormatter {
    static let logTimestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}
