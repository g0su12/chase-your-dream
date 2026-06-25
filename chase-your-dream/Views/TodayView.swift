import SwiftData
import SwiftUI

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme

    @AppStorage(AppStorageKeys.selectedLanguage) private var selectedLanguageRaw: String = AppLanguage.vi.rawValue
    @Query(sort: \FavoriteRecord.createdAt, order: .reverse) private var favorites: [FavoriteRecord]

    @StateObject private var viewModel: TodayViewModel

    init(service: DailyContentServicing) {
        _viewModel = StateObject(wrappedValue: TodayViewModel(service: service))
    }

    private var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: selectedLanguageRaw) ?? .vi
    }

    private var taskID: String {
        "\(DayKeyFormatter.key(for: viewModel.selectedDate))_\(selectedLanguage.rawValue)"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                HealingTheme.screenBackground(for: colorScheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        datePickerSection
                            .healingCard(colorScheme: colorScheme)

                        if let previousSummary = viewModel.previousSummary {
                            previousSummarySection(summary: previousSummary)
                                .healingCard(colorScheme: colorScheme, tint: HealingTheme.panelBackground(for: colorScheme))
                        }

                        if viewModel.isLoading {
                            loadingSection
                                .healingCard(colorScheme: colorScheme)
                                .transition(.opacity)
                        } else if let package = viewModel.dailyPackage {
                            quoteSection(package: package)
                                .healingCard(colorScheme: colorScheme, tint: HealingTheme.quoteTint(for: colorScheme))
                                .transition(.opacity)

                            storySection(package: package)
                                .healingCard(colorScheme: colorScheme, tint: HealingTheme.storyTint(for: colorScheme))

                            reflectionSection(prompt: package.reflectionPrompt)
                                .healingCard(colorScheme: colorScheme)

                            actionsSection(actions: package.microActions)
                                .healingCard(colorScheme: colorScheme)

                            completionSection
                                .healingCard(colorScheme: colorScheme)

                            moodSection
                                .healingCard(colorScheme: colorScheme)

                            journalSection
                                .healingCard(colorScheme: colorScheme)

                            saveSection

                            if let feedback = viewModel.latestFeedback {
                                feedbackSection(feedback: feedback)
                                    .healingCard(colorScheme: colorScheme, tint: HealingTheme.successTint(for: colorScheme))
                            }

                            if let tomorrowSuggestion = viewModel.tomorrowSuggestion {
                                tomorrowSuggestionSection(suggestion: tomorrowSuggestion)
                                    .healingCard(colorScheme: colorScheme, tint: HealingTheme.suggestionTint(for: colorScheme))
                            }

                            safetyNoteSection
                        } else {
                            Text(localized(vi: "Chưa có nội dung cho ngày này.", en: "No content for this day yet."))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .healingCard(colorScheme: colorScheme)
                                .transition(.opacity)
                        }

                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .healingCard(colorScheme: colorScheme)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(localized(vi: "Hôm nay", en: "Today"))
            .tint(HealingTheme.primaryAccent(for: colorScheme))
            .task(id: taskID) {
                await viewModel.load(language: selectedLanguage, modelContext: modelContext)
            }
            .refreshable {
                await viewModel.load(language: selectedLanguage, modelContext: modelContext)
            }
            .animation(.easeInOut(duration: 0.25), value: viewModel.isLoading)
            .animation(.easeInOut(duration: 0.25), value: viewModel.dailyPackage?.id)
        }
    }

    private var datePickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(localized(vi: "Ngày mục tiêu", en: "Focus day"))
                .font(.headline)

            DatePicker(
                "",
                selection: $viewModel.selectedDate,
                displayedComponents: .date
            )
            .labelsHidden()
            .datePickerStyle(.compact)
        }
    }

    private func previousSummarySection(summary: PreviousCheckinSummary) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(localized(vi: "Tổng kết hôm qua", en: "Yesterday summary"))
                .font(.headline)

            Text("\(summary.dateKey) - \(summary.completionPercent)%")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(summary.feedback)
                .font(.subheadline)
        }
    }

    private var loadingSection: some View {
        HStack(spacing: 12) {
            ProgressView()
            Text(localized(vi: "Đang tải nội dung hôm nay...", en: "Loading daily package..."))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func quoteSection(package: DailyPackage) -> some View {
        let favoriteID = "quote-\(package.dateKey)"
        let quoteToShare = "\(package.quote.text) - \(package.quote.author)"

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(localized(vi: "Trích dẫn", en: "Quote"))
                    .font(.headline)
                Spacer()
                ShareLink(item: quoteToShare) {
                    Image(systemName: "square.and.arrow.up")
                }
                Button {
                    toggleFavorite(
                        id: favoriteID,
                        type: .quote,
                        contentText: package.quote.text,
                        detailText: package.quote.author
                    )
                } label: {
                    Image(systemName: isFavorite(id: favoriteID) ? "star.fill" : "star")
                }
            }

            Text("\"\(package.quote.text)\"")
                .font(.title3)

            Text(package.quote.author)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .overlay(alignment: .topTrailing) {
            SunDoodleIllustration()
                .scaleEffect(0.72)
                .opacity(colorScheme == .dark ? 0.30 : 0.46)
                .offset(x: 12, y: -8)
        }
    }

    private func storySection(package: DailyPackage) -> some View {
        let favoriteID = "story-\(package.dateKey)"

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(localized(vi: "Câu chuyện ngắn", en: "Short story"))
                    .font(.headline)
                Spacer()
                Button {
                    toggleFavorite(
                        id: favoriteID,
                        type: .story,
                        contentText: package.story.title,
                        detailText: package.story.body
                    )
                } label: {
                    Image(systemName: isFavorite(id: favoriteID) ? "star.fill" : "star")
                }
            }

            Text(package.story.title)
                .font(.subheadline)
                .fontWeight(.semibold)

            Text(package.story.body)
                .font(.subheadline)
        }
        .overlay(alignment: .bottomTrailing) {
            WaveDoodleIllustration()
                .opacity(colorScheme == .dark ? 0.34 : 0.55)
                .offset(x: 10, y: 8)
        }
    }

    private func reflectionSection(prompt: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(localized(vi: "Tự vấn", en: "Reflection"))
                .font(.headline)

            Text(prompt)
                .font(.subheadline)
        }
        .overlay(alignment: .bottomTrailing) {
            LeafCornerIllustration()
                .opacity(colorScheme == .dark ? 0.42 : 0.62)
                .offset(x: 4, y: 6)
        }
    }

    private func actionsSection(actions: [MicroAction]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(localized(vi: "Hành động nhỏ", en: "Micro actions"))
                .font(.headline)

            ForEach(actions) { action in
                Button {
                    viewModel.toggleAction(action.id)
                } label: {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: viewModel.completedActionIDs.contains(action.id) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(viewModel.completedActionIDs.contains(action.id) ? .green : .secondary)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(action.title)
                                .foregroundStyle(.primary)
                            Text("\(action.detail) (\(action.recommendedMinutes)m)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var completionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(localized(vi: "Tiến độ", en: "Completion"))
                    .font(.headline)
                Spacer()
                Text("\(Int(viewModel.completionPercent))%")
                    .font(.headline)
            }

            Slider(value: $viewModel.completionPercent, in: 0...100, step: 1)
        }
    }

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(localized(vi: "Tâm trạng", en: "Mood"))
                .font(.headline)

            MoodSliderSelector(moodLevel: $viewModel.moodLevel)

            Text(localized(vi: "Kéo hoặc chạm để chọn mức cảm xúc", en: "Slide or tap to pick your mood"))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var journalSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(localized(vi: "Nhật ký ngắn", en: "Short journal"))
                .font(.headline)

            TextEditor(text: $viewModel.journalNote)
                .frame(minHeight: 110)
                .padding(8)
                .scrollContentBackground(.hidden)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(HealingTheme.panelBackground(for: colorScheme))
                        .overlay(.ultraThinMaterial.opacity(colorScheme == .dark ? 0.28 : 0.16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(HealingTheme.cardStroke(for: colorScheme), lineWidth: 0.8)
                        )
                )
        }
    }

    private var saveSection: some View {
        Button {
            viewModel.saveCheckin(language: selectedLanguage, modelContext: modelContext)
        } label: {
            Text(localized(vi: "Lưu check-in", en: "Save check-in"))
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(HealingTheme.primaryAccent(for: colorScheme))
    }

    private func feedbackSection(feedback: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(localized(vi: "Thông điệp động lực", en: "Motivation message"))
                .font(.headline)
            Text(feedback)
                .font(.subheadline)
        }
    }

    private func tomorrowSuggestionSection(suggestion: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(localized(vi: "Gợi ý cho ngày mai", en: "Tomorrow suggestion"))
                .font(.headline)
            Text(suggestion)
                .font(.subheadline)
        }
    }

    private var safetyNoteSection: some View {
        Text(NextStepEngine.safetyNote(language: selectedLanguage))
            .font(.footnote)
            .foregroundStyle(.secondary)
    }

    private func localized(vi: String, en: String) -> String {
        selectedLanguage == .vi ? vi : en
    }

    private func isFavorite(id: String) -> Bool {
        let normalizedID = MockDailyContentService.normalizedFavoriteID(id)
        return favorites.contains { item in
            MockDailyContentService.normalizedFavoriteID(item.id, type: item.type) == normalizedID
        }
    }

    private func toggleFavorite(id: String, type: FavoriteContentType, contentText: String, detailText: String) {
        let normalizedID = MockDailyContentService.normalizedFavoriteID(id, type: type)
        let matched = favorites.filter {
            MockDailyContentService.normalizedFavoriteID($0.id, type: $0.type) == normalizedID
        }

        if !matched.isEmpty {
            matched.forEach(modelContext.delete)
        } else {
            modelContext.insert(
                FavoriteRecord(
                    id: normalizedID,
                    type: type,
                    contentText: contentText,
                    detailText: detailText
                )
            )
        }

        try? modelContext.save()
    }
}
