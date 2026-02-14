import SwiftUI
import AppKit
import Foundation

enum AppAppearanceMode: String, CaseIterable, Identifiable {
    case light
    case dark

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .light:
            return "sun.max"
        case .dark:
            return "moon.stars"
        }
    }

    var textKey: AppTextKey {
        switch self {
        case .light:
            return .appearanceLightDay
        case .dark:
            return .appearanceDarkMoon
        }
    }

    var preferredColorScheme: ColorScheme {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

private struct SurgePalette {
    let isDark: Bool
    let canvasTop: Color
    let canvasBottom: Color
    let flowA: Color
    let flowB: Color
    let flowC: Color
    let textPrimary: Color
    let textSecondary: Color
    let cardStroke: Color
    let logBackground: Color
    let logText: Color

    static let dark = SurgePalette(
        isDark: true,
        canvasTop: Color(red: 0.03, green: 0.08, blue: 0.16),
        canvasBottom: Color(red: 0.02, green: 0.13, blue: 0.24),
        flowA: Color(red: 0.11, green: 0.41, blue: 0.74),
        flowB: Color(red: 0.16, green: 0.64, blue: 0.88),
        flowC: Color(red: 0.06, green: 0.29, blue: 0.56),
        textPrimary: Color.white.opacity(0.95),
        textSecondary: Color.white.opacity(0.72),
        cardStroke: Color.white.opacity(0.28),
        logBackground: Color.black.opacity(0.44),
        logText: Color.white.opacity(0.9)
    )

    static let light = SurgePalette(
        isDark: false,
        canvasTop: Color(red: 0.90, green: 0.93, blue: 0.96),
        canvasBottom: Color(red: 0.84, green: 0.89, blue: 0.94),
        flowA: Color(red: 0.27, green: 0.48, blue: 0.70),
        flowB: Color(red: 0.20, green: 0.42, blue: 0.64),
        flowC: Color(red: 0.43, green: 0.60, blue: 0.78),
        textPrimary: Color.black.opacity(0.85),
        textSecondary: Color.black.opacity(0.60),
        cardStroke: Color.black.opacity(0.14),
        logBackground: Color.white.opacity(0.72),
        logText: Color.black.opacity(0.83)
    )

    static func resolved(for colorScheme: ColorScheme) -> SurgePalette {
        colorScheme == .dark ? .dark : .light
    }

    func surface(_ darkOpacity: Double, _ lightOpacity: Double) -> Color {
        Color.white.opacity(isDark ? darkOpacity : lightOpacity)
    }

    func stroke(_ darkOpacity: Double, _ lightOpacity: Double) -> Color {
        isDark ? Color.white.opacity(darkOpacity) : Color.black.opacity(lightOpacity)
    }

    func neutral(_ darkOpacity: Double, _ lightOpacity: Double) -> Color {
        isDark ? Color.white.opacity(darkOpacity) : Color.black.opacity(lightOpacity)
    }
}

private struct SurgePaletteKey: EnvironmentKey {
    static let defaultValue: SurgePalette = .dark
}

private extension EnvironmentValues {
    var surgePalette: SurgePalette {
        get { self[SurgePaletteKey.self] }
        set { self[SurgePaletteKey.self] = newValue }
    }
}

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()

    private var resolvedColorScheme: ColorScheme {
        viewModel.preferredColorScheme
    }

    private var palette: SurgePalette {
        SurgePalette.resolved(for: resolvedColorScheme)
    }

    var body: some View {
        ZStack {
            background

            ScrollView {
                VStack(spacing: 16) {
                    headerCard
                    stepCard
                    stepOneCard
                    stepTwoCard
                    stepThreeCard
                    stepFourCard
                }
                .frame(maxWidth: 1180)
                .padding(.horizontal, 28)
                .padding(.vertical, 24)
            }
            .scrollIndicators(.hidden)
        }
        .alert(text(.alertWriteTitle), isPresented: $viewModel.showWriteConfirmation) {
            Button(text(.buttonCancel), role: .cancel) {
                viewModel.cancelWriteConfirmation()
            }
            Button(text(.buttonConfirmWrite)) {
                viewModel.performWriteConfirmed()
            }
        } message: {
            Text(viewModel.pendingWriteSummary)
        }
        .preferredColorScheme(viewModel.preferredColorScheme)
        .environment(\.surgePalette, palette)
    }

    private func text(_ key: AppTextKey) -> String {
        viewModel.text(key)
    }

    private func format(_ key: AppTextKey, _ arguments: CVarArg...) -> String {
        viewModel.format(key, arguments: arguments)
    }

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [
                    palette.canvasTop,
                    palette.canvasBottom
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [palette.flowA.opacity(palette.isDark ? 0.55 : 0.20), .clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 680
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [palette.flowB.opacity(palette.isDark ? 0.42 : 0.16), .clear],
                center: .bottomLeading,
                startRadius: 40,
                endRadius: 720
            )
            .ignoresSafeArea()

            RoundedRectangle(cornerRadius: 280, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            palette.flowA.opacity(palette.isDark ? 0.42 : 0.17),
                            palette.flowC.opacity(palette.isDark ? 0.18 : 0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 860, height: 430)
                .blur(radius: 120)
                .offset(x: -330, y: -300)

            RoundedRectangle(cornerRadius: 260, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            palette.flowB.opacity(palette.isDark ? 0.38 : 0.15),
                            palette.flowC.opacity(palette.isDark ? 0.14 : 0.07)
                        ],
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                )
                .frame(width: 760, height: 420)
                .blur(radius: 115)
                .offset(x: 360, y: 280)
        }
    }

    private var headerCard: some View {
        GlassCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Label(text(.appTitle), systemImage: "books.vertical.fill")
                        .font(.custom("Songti SC", size: 31).weight(.bold))
                        .foregroundStyle(palette.textPrimary)
                    Text(text(.appSubtitle))
                        .font(.custom("Songti SC", size: 16).weight(.medium))
                        .foregroundStyle(palette.textSecondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    HStack(spacing: 8) {
                        appearanceMenu
                        languageMenu
                    }
                    CountChip(title: text(.chipPDFFiles), value: "\(viewModel.items.count)")
                    CountChip(title: text(.chipCurrentStatus), value: viewModel.currentStageName)
                    CountChip(title: text(.chipVersion), value: appVersionText)
                }
            }
        }
    }

    private var appearanceMenu: some View {
        Menu {
            ForEach(AppAppearanceMode.allCases) { mode in
                Button {
                    viewModel.setAppearanceMode(mode)
                } label: {
                    HStack {
                        Text(viewModel.appearanceModeLabel(mode))
                        if viewModel.appearanceMode == mode {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: viewModel.appearanceMode.iconName)
                Text("\(text(.chipAppearance)): \(viewModel.appearanceModeLabel(viewModel.appearanceMode))")
                    .lineLimit(1)
            }
            .font(.custom("Songti SC", size: 13).weight(.semibold))
            .foregroundStyle(palette.textPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Capsule().fill(palette.surface(0.13, 0.64)))
            .overlay(
                Capsule().stroke(palette.stroke(0.28, 0.16), lineWidth: 1)
            )
        }
        .menuStyle(.borderlessButton)
    }

    private var languageMenu: some View {
        Menu {
            ForEach(AppLanguage.supportedTopTen) { language in
                Button {
                    viewModel.setLanguage(language)
                } label: {
                    HStack {
                        Text(language.nativeName)
                        if viewModel.language == language {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "globe")
                Text("\(text(.chipLanguage)): \(viewModel.language.nativeName)")
                    .lineLimit(1)
            }
            .font(.custom("Songti SC", size: 13).weight(.semibold))
            .foregroundStyle(palette.textPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Capsule().fill(palette.surface(0.13, 0.64)))
            .overlay(
                Capsule().stroke(palette.stroke(0.28, 0.16), lineWidth: 1)
            )
        }
        .menuStyle(.borderlessButton)
    }

    private var appVersionText: String {
        let short = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "dev"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? short

        if short.isEmpty { return build }
        if build.isEmpty || build == short { return short }
        return "\(short)-\(build)"
    }

    private var stepCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                CardTitle(text(.flowTitle))
                HStack(spacing: 10) {
                    StepPill(index: 1, title: text(.stepOne), activeStep: viewModel.currentStep)
                        .frame(maxWidth: .infinity, minHeight: 64, maxHeight: 64)
                    StepPill(index: 2, title: text(.stepTwo), activeStep: viewModel.currentStep)
                        .frame(maxWidth: .infinity, minHeight: 64, maxHeight: 64)
                    StepPill(index: 3, title: text(.stepThree), activeStep: viewModel.currentStep)
                        .frame(maxWidth: .infinity, minHeight: 64, maxHeight: 64)
                    StepPill(index: 4, title: text(.stepFour), activeStep: viewModel.currentStep)
                        .frame(maxWidth: .infinity, minHeight: 64, maxHeight: 64)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var stepOneCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                CardTitle(text(.cardOneTitle))

                HStack(spacing: 10) {
                    FieldBlock(title: text(.fieldSelectedPath), placeholder: text(.fieldSelectedPathPlaceholder), text: $viewModel.sourcePath)
                        .frame(maxWidth: .infinity)
                    Button(text(.buttonChoose)) { viewModel.pickSource() }
                        .buttonStyle(SecondaryButton())
                        .frame(width: 100)
                    Button(text(.buttonLoadPDF)) { viewModel.loadPDFsFromSource() }
                        .buttonStyle(PrimaryButton())
                        .frame(width: 100)
                }

                Text(text(.folderScanHint))
                    .font(.custom("Songti SC", size: 13))
                    .foregroundStyle(palette.textSecondary)

                Text(text(.loadedPDFList))
                    .font(.custom("Songti SC", size: 14).weight(.semibold))
                    .foregroundStyle(palette.textPrimary)

                if viewModel.items.isEmpty {
                    Text(text(.noPDFLoaded))
                        .foregroundStyle(palette.textSecondary)
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.items) { item in
                            PDFItemRow(
                                item: item,
                                language: viewModel.language,
                                isSelected: viewModel.selectedItemID == item.id,
                                onTap: { viewModel.selectItem(item.id) }
                            )
                        }
                    }
                }
            }
        }
    }

    private var stepTwoCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                CardTitle(text(.cardTwoTitle))

                if let item = viewModel.selectedItem {
                    HStack(alignment: .top, spacing: 10) {
                        VStack(alignment: .leading, spacing: 6) {
                            FieldBlock(
                                title: text(.hintFileNameLabel),
                                placeholder: text(.hintFileNamePlaceholder),
                                text: Binding(
                                    get: { viewModel.searchHintFileName(for: item.id) },
                                    set: { viewModel.updateSearchHintFileName($0, for: item.id) }
                                )
                            )

                            FieldBlock(
                                title: text(.hintExtractedTitleLabel),
                                placeholder: text(.hintExtractedTitlePlaceholder),
                                text: Binding(
                                    get: { viewModel.searchHintExtractedTitle(for: item.id) },
                                    set: { viewModel.updateSearchHintExtractedTitle($0, for: item.id) }
                                )
                            )

                            if let isbn = item.hint.isbn {
                                Text(format(.hintISBN, isbn))
                                    .font(.custom("Songti SC", size: 13).weight(.medium))
                            }
                            if let doi = item.hint.doi {
                                Text(format(.hintDOI, doi))
                                    .font(.custom("Songti SC", size: 13).weight(.medium))
                            }
                            if !item.hint.snippet.isEmpty {
                                Text(format(.hintSnippet, item.hint.snippet))
                                    .font(.custom("Songti SC", size: 13).weight(.medium))
                                    .lineLimit(2)
                            }
                        }
                        .foregroundStyle(palette.textSecondary)
                        .frame(maxWidth: .infinity, minHeight: 170, alignment: .topLeading)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(palette.surface(0.08, 0.62))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(palette.stroke(0.18, 0.14), lineWidth: 1)
                        )

                        VStack(alignment: .leading, spacing: 6) {
                            Toggle(text(.sourceOpenLibrary), isOn: $viewModel.sourceOptions.useOpenLibrary)
                                .toggleStyle(.switch)
                            Toggle(text(.sourceGoogleBooks), isOn: $viewModel.sourceOptions.useGoogleBooks)
                                .toggleStyle(.switch)
                            Toggle(text(.sourceDouban), isOn: $viewModel.sourceOptions.useDoubanWebSearch)
                                .toggleStyle(.switch)
                            Toggle(text(.sourceLOC), isOn: $viewModel.sourceOptions.useLibraryOfCongress)
                                .toggleStyle(.switch)
                        }
                        .font(.custom("Songti SC", size: 14).weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 170, alignment: .topLeading)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(palette.surface(0.08, 0.62))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(palette.stroke(0.18, 0.14), lineWidth: 1)
                        )
                    }

                    HStack(spacing: 8) {
                        Button(viewModel.isSearching ? text(.buttonSearching) : text(.buttonSearchMetadata)) {
                            viewModel.searchMetadataForSelectedItem()
                        }
                        .buttonStyle(PrimaryButton())
                        .disabled(viewModel.isSearching)

                        Text(text(.searchStrategy))
                            .font(.custom("Songti SC", size: 12))
                            .foregroundStyle(palette.textSecondary)
                    }

                    if item.candidates.isEmpty {
                        Text(text(.noCandidates))
                            .font(.custom("Songti SC", size: 13))
                            .foregroundStyle(palette.textSecondary)
                    } else {
                        VStack(alignment: .leading, spacing: 7) {
                            ForEach(item.candidates) { candidate in
                                CandidateRow(
                                    candidate: candidate,
                                    language: viewModel.language,
                                    selected: item.selectedCandidateID == candidate.id,
                                    onTap: { viewModel.chooseCandidate(candidate.id, for: item.id) }
                                )
                            }
                        }
                    }
                } else {
                    Text(text(.loadAndSelectFirst))
                        .foregroundStyle(palette.textSecondary)
                }
            }
        }
    }

    private var stepThreeCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                CardTitle(text(.cardThreeTitle))

                if let item = viewModel.selectedItem {
                    let selectedCandidate = item.candidates.first(where: { $0.id == item.selectedCandidateID })
                    let canEditValues = selectedCandidate != nil

                    VStack(alignment: .leading, spacing: 6) {
                        if let candidate = selectedCandidate {
                            Text(format(.selectedCandidate, candidate.primaryTitle))
                                .font(.custom("Songti SC", size: 14).weight(.semibold))
                                .foregroundStyle(palette.textPrimary)
                            Text(format(.sourceConfidence, candidate.source, candidate.confidence))
                                .font(.custom("Songti SC", size: 12))
                                .foregroundStyle(palette.textSecondary)
                        } else {
                            Text(text(.noSelectedCandidate))
                                .font(.custom("Songti SC", size: 13))
                                .foregroundStyle(palette.textSecondary)
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(text(.dublinFieldsTitle))
                            .font(.custom("Songti SC", size: 14).weight(.semibold))
                            .foregroundStyle(palette.textPrimary)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 190), spacing: 8)], spacing: 6) {
                            ForEach(DublinCoreField.allCases, id: \.self) { field in
                                let rawPreview = viewModel.editableDublinCoreValues[field]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                                let preview = rawPreview.isEmpty ? "—" : rawPreview

                                Toggle(isOn: Binding(
                                    get: { viewModel.selectedDublinCoreFields.contains(field) },
                                    set: { viewModel.setDublinCoreField(field, enabled: $0) }
                                )) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(field.rawValue)
                                            .font(.custom("Songti SC", size: 13).weight(.medium))
                                            .foregroundStyle(palette.textPrimary)

                                        TextField(
                                            text(.fieldValuePlaceholder),
                                            text: Binding(
                                                get: { viewModel.editableDublinCoreValues[field] ?? "" },
                                                set: { viewModel.updateEditableDublinCoreValue($0, for: field) }
                                            ),
                                            axis: .vertical
                                        )
                                        .textFieldStyle(.plain)
                                        .lineLimit(1...2)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 6)
                                        .font(.custom("Songti SC", size: 12).weight(.medium))
                                        .foregroundStyle(palette.textPrimary)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .fill(palette.surface(0.08, 0.62))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .stroke(palette.stroke(0.18, 0.14), lineWidth: 1)
                                        )
                                        .disabled(!canEditValues)

                                        Text(format(.fieldCurrentValue, preview))
                                            .font(.custom("Songti SC", size: 11))
                                            .foregroundStyle(palette.textSecondary)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .toggleStyle(.checkbox)
                            }
                        }

                        Text(format(.selectedFieldsCount, viewModel.selectedDublinCoreFields.count))
                            .font(.custom("Songti SC", size: 12))
                            .foregroundStyle(palette.textSecondary)
                    }

                    HStack(spacing: 8) {
                        Button(text(.buttonConfirmWriteDublin)) {
                            viewModel.askWriteConfirmationForSelectedItem()
                        }
                        .buttonStyle(PrimaryButton())
                        .disabled(item.selectedCandidateID == nil)

                        Text(text(.editableHint))
                            .font(.custom("Songti SC", size: 13))
                            .foregroundStyle(palette.textSecondary)
                    }
                } else {
                    Text(text(.loadAndSelectFirst))
                        .foregroundStyle(palette.textSecondary)
                }
            }
        }
    }

    private var stepFourCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                CardTitle(text(.cardFourTitle))

                if let prompt = viewModel.renamePrompt {
                    Text(format(.suggestedFileName, prompt.suggestedFileName))
                        .font(.custom("Songti SC", size: 14).weight(.semibold))

                    Text(text(.renameRule))
                        .font(.custom("Songti SC", size: 13))
                        .foregroundStyle(palette.textSecondary)

                    Text(text(.renameRuleNote))
                        .font(.custom("Songti SC", size: 12))
                        .foregroundStyle(palette.textSecondary)

                    HStack(spacing: 8) {
                        Button(text(.buttonRename)) {
                            viewModel.confirmRenameForPrompt()
                        }
                        .buttonStyle(PrimaryButton())

                        Button(text(.buttonSkipRename)) {
                            viewModel.skipRenameForPrompt()
                        }
                        .buttonStyle(SecondaryButton())
                    }
                } else {
                    Text(text(.noRenamePrompt))
                        .foregroundStyle(palette.textSecondary)
                }

                Divider()
                    .overlay(palette.stroke(0.2, 0.12))

                Text(text(.executionLog))
                    .font(.custom("Songti SC", size: 14).weight(.semibold))
                    .foregroundStyle(palette.textPrimary)
                Text(viewModel.status)
                    .font(.custom("Songti SC", size: 13).weight(.semibold))
                    .foregroundStyle(palette.textPrimary)

                if viewModel.logs.isEmpty {
                    Text(text(.noLogs))
                        .foregroundStyle(palette.textSecondary)
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(viewModel.logs.suffix(120).enumerated()), id: \.offset) { _, line in
                            Text(line)
                                .font(.custom("Menlo", size: 12))
                                .foregroundStyle(palette.logText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(palette.logBackground)
                    )
                }
            }
        }
    }
}

struct PDFItemRow: View {
    @Environment(\.surgePalette) private var palette
    let item: PDFWorkItem
    let language: AppLanguage
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? palette.flowB : palette.neutral(0.45, 0.36))
                    .font(.custom("Songti SC", size: 16).weight(.semibold))
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(item.url.lastPathComponent)
                            .font(.custom("Songti SC", size: 15).weight(.semibold))
                            .foregroundStyle(palette.textPrimary)
                        Spacer()
                        StageBadge(stage: item.stage)
                    }

                    Text(item.url.path)
                        .font(.custom("Menlo", size: 12))
                        .foregroundStyle(palette.textSecondary)
                        .lineLimit(1)

                    Text(AppLocalization.format(.contentHint, language: language, arguments: [item.hint.extractedTitle]))
                        .font(.custom("Songti SC", size: 13).weight(.medium))
                        .foregroundStyle(palette.textSecondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isSelected ? palette.surface(0.17, 0.82) : palette.surface(0.09, 0.62))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isSelected ? palette.flowB.opacity(0.75) : palette.stroke(0.20, 0.14), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct CandidateRow: View {
    @Environment(\.surgePalette) private var palette
    let candidate: BookMetadataCandidate
    let language: AppLanguage
    let selected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: selected ? "largecircle.fill.circle" : "circle")
                    .foregroundStyle(selected ? palette.flowB : palette.neutral(0.42, 0.34))
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(candidate.primaryTitle)
                            .font(.custom("Songti SC", size: 15).weight(.bold))
                            .foregroundStyle(palette.textPrimary)
                        Spacer()
                        Text("\(candidate.confidence)%")
                            .font(.custom("Songti SC", size: 12).weight(.bold))
                            .foregroundStyle(palette.flowB)
                    }

                    Text("\(candidate.kind.displayName) | \(candidate.authorsText)")
                        .font(.custom("Songti SC", size: 13).weight(.medium))
                        .foregroundStyle(palette.textSecondary)

                    Text("\(candidate.publisher) \(candidate.publishedYear)")
                        .font(.custom("Songti SC", size: 13))
                        .foregroundStyle(palette.textSecondary)

                    HStack(spacing: 6) {
                        if !candidate.isbn.isEmpty {
                            MiniChip(text: "ISBN: \(candidate.isbn)")
                        }
                        if !candidate.language.isEmpty {
                            MiniChip(text: AppLocalization.format(.chipLanguageCode, language: language, arguments: [candidate.language]))
                        }
                        if !candidate.validatedBy.isEmpty {
                            MiniChip(text: AppLocalization.format(.chipValidated, language: language, arguments: [candidate.validatedBy.joined(separator: "/")]))
                        }
                        MiniChip(text: candidate.source)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(selected ? palette.surface(0.16, 0.80) : palette.surface(0.08, 0.60))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(selected ? palette.flowB.opacity(0.7) : palette.stroke(0.20, 0.14), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct StepPill: View {
    @Environment(\.surgePalette) private var palette
    let index: Int
    let title: String
    let activeStep: Int

    var body: some View {
        let active = index <= activeStep

        HStack(spacing: 6) {
            Text("\(index)")
                .font(.custom("Songti SC", size: 12).weight(.bold))
                .frame(width: 18, height: 18)
                .background(
                    Circle().fill(active ? palette.flowB : palette.neutral(0.35, 0.24))
                )
                .foregroundStyle(active ? Color.white : palette.neutral(0.7, 0.72))

            Text(title)
                .font(.custom("Songti SC", size: 13).weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .allowsTightening(true)
                .multilineTextAlignment(.center)
                .foregroundStyle(active ? palette.textPrimary : palette.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(active ? palette.surface(0.18, 0.84) : palette.surface(0.09, 0.63))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(active ? palette.flowB.opacity(0.6) : palette.stroke(0.18, 0.14), lineWidth: 1)
        )
    }
}

struct StageBadge: View {
    let stage: PDFWorkflowStage

    var body: some View {
        Text(stage.displayName)
            .font(.custom("Songti SC", size: 11).weight(.bold))
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
    @Environment(\.surgePalette) private var palette
    let text: String

    var body: some View {
        Text(text)
            .font(.custom("Songti SC", size: 12).weight(.semibold))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(
                Capsule().fill(
                    LinearGradient(
                        colors: [
                            palette.flowB.opacity(palette.isDark ? 0.26 : 0.20),
                            palette.flowA.opacity(palette.isDark ? 0.16 : 0.14)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            )
            .foregroundStyle(palette.textPrimary)
            .lineLimit(1)
    }
}

struct GlassCard<Content: View>: View {
    @Environment(\.surgePalette) private var palette
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .foregroundStyle(palette.textPrimary)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [palette.surface(0.16, 0.62), palette.surface(0.03, 0.52)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [palette.stroke(0.48, 0.20), palette.cardStroke],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(palette.isDark ? 0.32 : 0.12), radius: 26, x: 0, y: 16)
    }
}

struct CardTitle: View {
    @Environment(\.surgePalette) private var palette
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.custom("Songti SC", size: 19).weight(.bold))
            .foregroundStyle(palette.textPrimary)
    }
}

struct CountChip: View {
    @Environment(\.surgePalette) private var palette
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.custom("Songti SC", size: 11).weight(.semibold))
                .foregroundStyle(palette.textSecondary)
            Text(value)
                .font(.custom("Songti SC", size: 13).weight(.bold))
                .foregroundStyle(palette.textPrimary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(palette.surface(0.12, 0.64)))
        .overlay(
            Capsule().stroke(palette.stroke(0.24, 0.15), lineWidth: 1)
        )
    }
}

struct FieldBlock: View {
    @Environment(\.surgePalette) private var palette
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.custom("Songti SC", size: 13).weight(.semibold))
                .foregroundStyle(palette.textSecondary)

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .font(.custom("Songti SC", size: 14).weight(.medium))
                .foregroundStyle(palette.textPrimary)
                .background(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(palette.surface(0.10, 0.66))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke(palette.stroke(0.22, 0.15), lineWidth: 1)
                )
        }
    }
}

struct SecureFieldBlock: View {
    @Environment(\.surgePalette) private var palette
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.custom("Songti SC", size: 13).weight(.semibold))
                .foregroundStyle(palette.textSecondary)

            SecureField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .font(.custom("Songti SC", size: 14).weight(.medium))
                .foregroundStyle(palette.textPrimary)
                .background(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(palette.surface(0.10, 0.66))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke(palette.stroke(0.22, 0.15), lineWidth: 1)
                )
        }
    }
}

struct PrimaryButton: ButtonStyle {
    @Environment(\.surgePalette) private var palette
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Songti SC", size: 14).weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 15)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [palette.flowA, palette.flowB],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(palette.stroke(0.35, 0.20), lineWidth: 1)
                    )
                    .shadow(color: palette.flowB.opacity(0.35), radius: 12, x: 0, y: 7)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .opacity(configuration.isPressed ? 0.86 : 1)
    }
}

struct SecondaryButton: ButtonStyle {
    @Environment(\.surgePalette) private var palette
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Songti SC", size: 13).weight(.bold))
            .foregroundStyle(palette.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(palette.surface(configuration.isPressed ? 0.16 : 0.10, configuration.isPressed ? 0.74 : 0.64))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(palette.stroke(0.24, 0.15), lineWidth: 1)
            )
    }
}

enum DublinCoreField: String, CaseIterable, Hashable {
    case title = "dc:title"
    case creator = "dc:creator"
    case publisher = "dc:publisher"
    case date = "dc:date"
    case language = "dc:language"
    case type = "dc:type"
    case format = "dc:format"
    case identifier = "dc:identifier"
    case subject = "dc:subject"
    case source = "dc:source"
    case relation = "dc:relation"
    case description = "dc:description"

    static var defaultSelected: [DublinCoreField] {
        [
            .title,
            .creator,
            .publisher,
            .date,
            .language,
            .type,
            .format,
            .identifier,
            .subject
        ]
    }
}

struct RenamePromptState {
    let itemID: UUID
    let suggestedFileName: String
}

@MainActor
final class MainViewModel: ObservableObject {
    private static let languageDefaultsKey = "app.language.code"
    private static let appearanceDefaultsKey = "app.appearance.mode"

    @Published var language: AppLanguage
    @Published var appearanceMode: AppAppearanceMode
    @Published var sourcePath: String = NSHomeDirectory()
    @Published var items: [PDFWorkItem] = []
    @Published var selectedItemID: UUID?
    @Published var sourceOptions = MetadataSourceOptions()
    @Published var selectedDublinCoreFields: Set<DublinCoreField> = Set(DublinCoreField.defaultSelected)
    @Published var editableDublinCoreValues: [DublinCoreField: String] = [:]

    @Published var status: String
    @Published var logs: [String] = []

    @Published var isSearching = false

    @Published var showWriteConfirmation = false
    @Published var pendingWriteSummary: String = ""

    private var pendingWriteItemID: UUID?
    @Published var renamePrompt: RenamePromptState?

    private struct EditableValuesContext: Hashable {
        let itemID: UUID
        let candidateID: UUID
    }

    private var editableValuesContext: EditableValuesContext?
    private var editableValuesCache: [EditableValuesContext: [DublinCoreField: String]] = [:]

    private let libraryService = PDFLibraryService()
    private let metadataService = MetadataService()
    private let fetcher = BookMetadataFetcher()
    private let renameService = BookRenameService()

    init() {
        let storedCode = UserDefaults.standard.string(forKey: Self.languageDefaultsKey)
        let initialLanguage = AppLanguage.from(code: storedCode) ?? AppLanguage.systemPreferred
        let storedAppearance = UserDefaults.standard.string(forKey: Self.appearanceDefaultsKey)
        let initialAppearance = AppAppearanceMode(rawValue: storedAppearance ?? "") ?? .light
        self.language = initialLanguage
        self.appearanceMode = initialAppearance
        AppLocalization.currentLanguage = initialLanguage
        self.status = AppLocalization.text(.statusReady, language: initialLanguage)
    }

    func text(_ key: AppTextKey) -> String {
        AppLocalization.text(key, language: language)
    }

    func format(_ key: AppTextKey, arguments: [CVarArg]) -> String {
        AppLocalization.format(key, language: language, arguments: arguments)
    }

    func setLanguage(_ newLanguage: AppLanguage) {
        guard newLanguage != language else { return }
        language = newLanguage
        AppLocalization.currentLanguage = newLanguage
        UserDefaults.standard.set(newLanguage.rawValue, forKey: Self.languageDefaultsKey)

        status = format(.statusLanguageChanged, arguments: [newLanguage.nativeName])
        appendLog(status)
    }

    func setAppearanceMode(_ newMode: AppAppearanceMode) {
        guard newMode != appearanceMode else { return }
        appearanceMode = newMode
        UserDefaults.standard.set(newMode.rawValue, forKey: Self.appearanceDefaultsKey)

        let modeText = text(newMode.textKey)
        status = format(.statusAppearanceChanged, arguments: [modeText])
        appendLog(status)
    }

    func appearanceModeLabel(_ mode: AppAppearanceMode) -> String {
        text(mode.textKey)
    }

    var preferredColorScheme: ColorScheme {
        appearanceMode.preferredColorScheme
    }

    var selectedItem: PDFWorkItem? {
        guard let selectedItemID,
              let item = items.first(where: { $0.id == selectedItemID })
        else {
            return nil
        }
        return item
    }

    var currentStageName: String {
        selectedItem?.stage.displayName ?? text(.stageNotStarted)
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
            syncEditableDublinCoreValuesForSelection()
            renamePrompt = nil
            status = format(.statusLoadedCount, arguments: [items.count])
            appendLog(status)
        } catch {
            status = format(.statusLoadFailed, arguments: [error.localizedDescription])
            appendLog(status)
        }
    }

    func selectItem(_ id: UUID) {
        selectedItemID = id
        syncEditableDublinCoreValuesForSelection()
    }

    func searchHintFileName(for itemID: UUID) -> String {
        items.first(where: { $0.id == itemID })?.hint.fileNameTitle ?? ""
    }

    func searchHintExtractedTitle(for itemID: UUID) -> String {
        items.first(where: { $0.id == itemID })?.hint.extractedTitle ?? ""
    }

    func updateSearchHintFileName(_ value: String, for itemID: UUID) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        let current = items[index].hint
        items[index].hint = rebuiltSearchHint(
            from: current,
            fileNameTitle: value,
            extractedTitle: current.extractedTitle
        )
    }

    func updateSearchHintExtractedTitle(_ value: String, for itemID: UUID) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        let current = items[index].hint
        items[index].hint = rebuiltSearchHint(
            from: current,
            fileNameTitle: current.fileNameTitle,
            extractedTitle: value
        )
    }

    func searchMetadataForSelectedItem() {
        guard let item = selectedItem else {
            status = text(.statusSelectPDFFirst)
            return
        }
        if isSearching {
            return
        }

        isSearching = true
        status = format(.statusSearching, arguments: [item.url.lastPathComponent])
        appendLog(status)

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
                self.items[index].lastError = self.text(.statusNoMatch)
                self.status = self.text(.statusNoMetadataFound)
            } else {
                self.items[index].stage = .searched
                self.status = self.format(.statusSearchComplete, arguments: [candidates.count])
            }
            if self.selectedItemID == itemID {
                self.syncEditableDublinCoreValuesForSelection()
            }
            self.appendLog(self.status)
            self.isSearching = false
        }
    }

    func chooseCandidate(_ candidateID: UUID, for itemID: UUID) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        items[index].selectedCandidateID = candidateID
        if selectedItemID == itemID {
            syncEditableDublinCoreValuesForSelection()
        }
    }

    func setDublinCoreField(_ field: DublinCoreField, enabled: Bool) {
        if enabled {
            selectedDublinCoreFields.insert(field)
        } else {
            selectedDublinCoreFields.remove(field)
        }
    }

    func updateEditableDublinCoreValue(_ value: String, for field: DublinCoreField) {
        editableDublinCoreValues[field] = value
        guard let context = editableValuesContext else { return }
        editableValuesCache[context] = editableDublinCoreValues
    }

    func askWriteConfirmationForSelectedItem() {
        guard let item = selectedItem,
              let candidate = selectedCandidate(for: item)
        else {
            status = text(.statusSelectCandidate)
            return
        }

        guard !selectedDublinCoreFields.isEmpty else {
            status = text(.statusSelectAtLeastOneField)
            appendLog(status)
            return
        }

        let entries = dublinCoreEntries(for: item, candidate: candidate)
        let preview = entries
            .sorted(by: { $0.key < $1.key })
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "\n")

        pendingWriteItemID = item.id
        pendingWriteSummary = format(.statusWritePreview, arguments: [preview])
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
            status = text(.statusWriteFailedMissingItem)
            appendLog(status)
            return
        }

        let url = items[index].url

        guard !selectedDublinCoreFields.isEmpty else {
            status = text(.statusWriteFailedNoFields)
            appendLog(status)
            return
        }

        let entries = dublinCoreEntries(for: items[index], candidate: candidate)

        do {
            try metadataService.writeMetadata(fileURL: url, entries: entries)
            items[index].stage = .written
            status = format(.statusWriteSuccess, arguments: [url.lastPathComponent])
            appendLog(status)

            let suggested = renameService.suggestedFileName(for: candidate, originalExtension: url.pathExtension)
            renamePrompt = RenamePromptState(itemID: itemID, suggestedFileName: suggested)
        } catch {
            items[index].stage = .failed
            items[index].lastError = error.localizedDescription
            status = format(.statusWriteFailed, arguments: [error.localizedDescription])
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
            status = text(.statusRenameMissingContext)
            appendLog(status)
            return
        }

        let oldURL = items[index].url

        do {
            let newURL = try renameService.renameFile(at: oldURL, using: candidate)
            items[index].url = newURL
            items[index].stage = .renamed
            status = format(.statusRenameSuccess, arguments: [oldURL.lastPathComponent, newURL.lastPathComponent])
            appendLog(status)
            renamePrompt = nil
        } catch {
            items[index].stage = .failed
            items[index].lastError = error.localizedDescription
            status = format(.statusRenameFailed, arguments: [error.localizedDescription])
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
        status = format(.statusRenameSkipped, arguments: [items[index].url.lastPathComponent])
        appendLog(status)
        renamePrompt = nil
    }

    private func selectedCandidate(for item: PDFWorkItem) -> BookMetadataCandidate? {
        guard let id = item.selectedCandidateID else { return nil }
        return item.candidates.first(where: { $0.id == id })
    }

    private func rebuiltSearchHint(
        from base: PDFSearchHint,
        fileNameTitle: String,
        extractedTitle: String
    ) -> PDFSearchHint {
        let file = fileNameTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let extracted = extractedTitle.trimmingCharacters(in: .whitespacesAndNewlines)

        var queryCandidates: [String] = []
        if let isbn = base.isbn?.trimmingCharacters(in: .whitespacesAndNewlines), !isbn.isEmpty {
            queryCandidates.append("isbn \(isbn)")
            queryCandidates.append(isbn)
        }
        if let doi = base.doi?.trimmingCharacters(in: .whitespacesAndNewlines), !doi.isEmpty {
            queryCandidates.append(doi)
        }
        if !extracted.isEmpty {
            queryCandidates.append(extracted)
        }
        if !file.isEmpty && file != extracted {
            queryCandidates.append(file)
        }

        let uniqueQueries = Array(NSOrderedSet(array: queryCandidates)) as? [String] ?? queryCandidates
        return PDFSearchHint(
            fileNameTitle: file,
            extractedTitle: extracted,
            snippet: base.snippet,
            isbn: base.isbn,
            doi: base.doi,
            queryCandidates: uniqueQueries
        )
    }

    func dublinCoreValueMap(for candidate: BookMetadataCandidate, fileURL: URL) -> [DublinCoreField: String] {
        let dcIdentifier: String = {
            if !candidate.isbn.isEmpty { return "isbn:\(candidate.isbn)" }
            if !candidate.doi.isEmpty { return "doi:\(candidate.doi)" }
            if !candidate.sourceURL.isEmpty { return candidate.sourceURL }
            return fileURL.lastPathComponent
        }()

        let typeSubject = candidate.kind == .paper ? "academic paper" : "book"
        let validationSummary = candidate.validatedBy.isEmpty ? "" : candidate.validatedBy.joined(separator: ", ")
        let description = [candidate.subtitle, validationSummary]
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .joined(separator: " | validation: ")

        return [
            .title: candidate.title,
            .creator: candidate.authorsText,
            .publisher: candidate.publisher,
            .date: candidate.publishedYear,
            .language: candidate.language,
            .type: "Text",
            .format: "application/pdf",
            .identifier: dcIdentifier,
            .source: candidate.source,
            .subject: typeSubject,
            .relation: candidate.sourceURL,
            .description: description
        ]
    }

    private func syncEditableDublinCoreValuesForSelection() {
        guard let item = selectedItem,
              let candidate = selectedCandidate(for: item)
        else {
            editableValuesContext = nil
            editableDublinCoreValues = [:]
            return
        }

        let context = EditableValuesContext(itemID: item.id, candidateID: candidate.id)
        editableValuesContext = context
        editableDublinCoreValues = editableValuesMap(for: item, candidate: candidate)
    }

    private func editableValuesMap(for item: PDFWorkItem, candidate: BookMetadataCandidate) -> [DublinCoreField: String] {
        let context = EditableValuesContext(itemID: item.id, candidateID: candidate.id)
        if let cached = editableValuesCache[context] {
            return cached
        }

        let generated = dublinCoreValueMap(for: candidate, fileURL: item.url)
        editableValuesCache[context] = generated
        return generated
    }

    private func dublinCoreEntries(for item: PDFWorkItem, candidate: BookMetadataCandidate) -> [String: String] {
        let all = editableValuesMap(for: item, candidate: candidate)

        var entries: [String: String] = [:]
        for field in DublinCoreField.allCases where selectedDublinCoreFields.contains(field) {
            entries[field.rawValue] = all[field] ?? ""
        }
        return entries
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
