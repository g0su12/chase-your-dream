import SwiftData
import SwiftUI

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme

    @AppStorage(AppStorageKeys.selectedLanguage) private var selectedLanguageRaw: String = AppLanguage.vi.rawValue
    @AppStorage(AppStorageKeys.selectedGoalsCSV) private var selectedGoalsCSV: String = PersonalGrowthGoal.defaultSelectionCSV
    @AppStorage(AppStorageKeys.dailyEnergyLevel) private var dailyEnergyLevelRaw: String = DailyEnergyLevel.steady.rawValue
    @Query(sort: \FavoriteRecord.createdAt, order: .reverse) private var favorites: [FavoriteRecord]

    @StateObject private var viewModel: TodayViewModel

    init(service: DailyContentServicing) {
        _viewModel = StateObject(wrappedValue: TodayViewModel(service: service))
    }

    private var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: selectedLanguageRaw) ?? .vi
    }

    private var personalization: DailyPersonalization {
        DailyPersonalization.fromStorage(
            goalsCSV: selectedGoalsCSV,
            energyLevelRaw: dailyEnergyLevelRaw
        )
    }

    private var dailyEnergyLevel: DailyEnergyLevel {
        DailyEnergyLevel(rawValue: dailyEnergyLevelRaw) ?? .steady
    }

    private var taskID: String {
        "\(DayKeyFormatter.key(for: viewModel.selectedDate))_\(selectedLanguage.rawValue)_\(personalization.cacheKey)"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                HealingTheme.screenBackground(for: colorScheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if viewModel.isLoading {
                            loadingSection
                                .healingCard(colorScheme: colorScheme)
                                .padding(.top, 8)
                        } else if let package = viewModel.dailyPackage {
                            sanctuaryHeader(package: package)

                            if let previousSummary = viewModel.previousSummary {
                                previousSummarySection(summary: previousSummary)
                            }

                            quoteSection(package: package)

                            actionsSection(actions: package.microActions)

                            checkInSection
                                .healingCard(colorScheme: colorScheme)

                            reflectionJournalSection(prompt: package.reflectionPrompt)
                                .healingCard(colorScheme: colorScheme)

                            storySection(package: package)

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
                                .padding(.top, 8)
                        }

                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .healingCard(colorScheme: colorScheme)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 22)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(localized(vi: "Hôm nay", en: "Today"))
            .navigationBarTitleDisplayMode(.inline)
            .tint(HealingTheme.primaryAccent(for: colorScheme))
            .task(id: taskID) {
                await viewModel.load(
                    language: selectedLanguage,
                    personalization: personalization,
                    modelContext: modelContext
                )
            }
            .refreshable {
                await viewModel.load(
                    language: selectedLanguage,
                    personalization: personalization,
                    modelContext: modelContext
                )
            }
            .animation(.easeInOut(duration: 0.25), value: viewModel.isLoading)
            .animation(.easeInOut(duration: 0.25), value: viewModel.dailyPackage?.id)
        }
    }

    private func sanctuaryHeader(package: DailyPackage) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(greetingTitle)
                        .font(.system(size: 31, weight: .semibold, design: .rounded))
                        .lineSpacing(3)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(greetingSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                SunDoodleIllustration()
                    .scaleEffect(0.9)
                    .opacity(colorScheme == .dark ? 0.46 : 0.72)
                    .accessibilityHidden(true)
            }

            DatePicker(
                "",
                selection: $viewModel.selectedDate,
                displayedComponents: .date
            )
            .labelsHidden()
            .datePickerStyle(.compact)

            focusPills
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(headerFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(HealingTheme.cardStroke(for: colorScheme), lineWidth: 1)
                )
        )
        .overlay(alignment: .bottomTrailing) {
            WaveDoodleIllustration()
                .scaleEffect(1.25)
                .opacity(colorScheme == .dark ? 0.20 : 0.36)
                .offset(x: 16, y: 6)
                .accessibilityHidden(true)
        }
        .shadow(
            color: colorScheme == .dark
                ? Color.black.opacity(0.28)
                : Color(red: 0.50, green: 0.56, blue: 0.48).opacity(0.16),
            radius: 14,
            x: 0,
            y: 8
        )
    }

    private var focusPills: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(personalization.goals) { goal in
                    Label {
                        Text(goal.title(language: selectedLanguage))
                            .font(.caption.weight(.medium))
                    } icon: {
                        Image(systemName: goal.systemImage)
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(HealingTheme.primaryAccent(for: colorScheme))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(
                        Capsule(style: .continuous)
                            .fill(HealingTheme.panelBackground(for: colorScheme))
                            .overlay(
                                Capsule(style: .continuous)
                                    .stroke(HealingTheme.cardStroke(for: colorScheme), lineWidth: 0.8)
                            )
                    )
                }
            }
            .padding(.vertical, 1)
        }
        .scrollIndicators(.hidden)
    }

    private var loadingSection: some View {
        HStack(spacing: 12) {
            ProgressView()
            Text(localized(vi: "Đang chuẩn bị một nhịp nhẹ cho hôm nay...", en: "Preparing a gentle rhythm for today..."))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func previousSummarySection(summary: PreviousCheckinSummary) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.title3)
                .foregroundStyle(HealingTheme.primaryAccent(for: colorScheme))
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(HealingTheme.panelBackground(for: colorScheme))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(localized(vi: "Hôm qua bạn đã quay lại", en: "You came back yesterday"))
                    .font(.headline)

                Text("\(summary.dateKey) - \(summary.completionPercent)%")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(summary.feedback)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(HealingTheme.panelBackground(for: colorScheme))
        )
    }

    private func quoteSection(package: DailyPackage) -> some View {
        let favoriteID = "quote-\(package.dateKey)"
        let quoteToShare = "\(package.quote.text) - \(package.quote.author)"

        return VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                sectionLabel(
                    title: localized(vi: "Khoảnh khắc để thở", en: "A Moment To Breathe"),
                    systemImage: "quote.opening"
                )

                Spacer()

                ShareLink(item: quoteToShare) {
                    Image(systemName: "square.and.arrow.up")
                        .frame(width: 36, height: 36)
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
                        .frame(width: 36, height: 36)
                }
            }

            Text("\"\(package.quote.text)\"")
                .font(.system(size: 25, weight: .medium, design: .serif))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)

            Text(package.quote.author)
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(HealingTheme.quoteTint(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(HealingTheme.cardStroke(for: colorScheme), lineWidth: 0.9)
                )
        )
        .overlay(alignment: .topTrailing) {
            LeafCornerIllustration()
                .scaleEffect(1.18)
                .opacity(colorScheme == .dark ? 0.28 : 0.52)
                .offset(x: 4, y: 8)
                .accessibilityHidden(true)
        }
    }

    private func actionsSection(actions: [MicroAction]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                sectionLabel(
                    title: localized(vi: "Ba bước nhỏ hôm nay", en: "Three Tiny Steps"),
                    systemImage: "figure.walk"
                )

                Text(localized(vi: "Chỉ cần chọn bước vừa sức nhất trước.", en: "Start with the step that feels most possible."))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 10) {
                ForEach(Array(actions.enumerated()), id: \.element.id) { index, action in
                    microActionRow(action: action, index: index)
                }
            }
        }
    }

    private func microActionRow(action: MicroAction, index: Int) -> some View {
        let isCompleted = viewModel.completedActionIDs.contains(action.id)

        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.86)) {
                viewModel.toggleAction(action.id)
            }
        } label: {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isCompleted ? HealingTheme.primaryAccent(for: colorScheme) : HealingTheme.panelBackground(for: colorScheme))

                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                    } else {
                        Text("\(index + 1)")
                            .font(.caption.weight(.bold))
                    }
                }
                .foregroundStyle(isCompleted ? Color.white : HealingTheme.primaryAccent(for: colorScheme))
                .frame(width: 34, height: 34)

                VStack(alignment: .leading, spacing: 5) {
                    Text(action.title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(action.detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Label("\(action.recommendedMinutes)m", systemImage: "timer")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(isCompleted ? HealingTheme.successTint(for: colorScheme) : HealingTheme.cardBackground(for: colorScheme))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(
                                isCompleted
                                    ? HealingTheme.primaryAccent(for: colorScheme).opacity(0.32)
                                    : HealingTheme.cardStroke(for: colorScheme),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var checkInSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionLabel(
                title: localized(vi: "Check-in nhẹ", en: "Gentle Check-in"),
                systemImage: "heart.text.square"
            )

            energySelector

            VStack(alignment: .leading, spacing: 9) {
                HStack {
                    Text(localized(vi: "Tâm trạng", en: "Mood"))
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(moodCaption)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                MoodSliderSelector(moodLevel: $viewModel.moodLevel)
                    .frame(height: 48)
            }

            completionControl
        }
    }

    private var energySelector: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Text(localized(vi: "Năng lượng", en: "Energy"))
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(dailyEnergyLevel.detail(language: selectedLanguage))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            HStack(spacing: 8) {
                ForEach(DailyEnergyLevel.allCases) { energyLevel in
                    Button {
                        withAnimation(.spring(response: 0.24, dampingFraction: 0.82)) {
                            dailyEnergyLevelRaw = energyLevel.rawValue
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: energyIcon(for: energyLevel))
                                .font(.headline)

                            Text(energyLevel.title(language: selectedLanguage))
                                .font(.caption.weight(.semibold))
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 70)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(
                                    energyLevel == dailyEnergyLevel
                                        ? HealingTheme.suggestionTint(for: colorScheme)
                                        : HealingTheme.panelBackground(for: colorScheme)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(
                                            energyLevel == dailyEnergyLevel
                                                ? HealingTheme.primaryAccent(for: colorScheme).opacity(0.45)
                                                : HealingTheme.cardStroke(for: colorScheme),
                                            lineWidth: 1
                                        )
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(energyLevel == dailyEnergyLevel ? HealingTheme.primaryAccent(for: colorScheme) : .secondary)
                }
            }
        }
    }

    private var completionControl: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(localized(vi: "Tiến độ hôm nay", en: "Today's Progress"))
                    .font(.subheadline.weight(.semibold))

                Spacer()

                Text("\(Int(viewModel.completionPercent))%")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(HealingTheme.primaryAccent(for: colorScheme))
            }

            ProgressView(value: viewModel.completionPercent, total: 100)
                .tint(HealingTheme.primaryAccent(for: colorScheme))

            Slider(value: $viewModel.completionPercent, in: 0...100, step: 1)
        }
    }

    private func reflectionJournalSection(prompt: String) -> some View {
        VStack(alignment: .leading, spacing: 13) {
            sectionLabel(
                title: localized(vi: "Một dòng cho mình", en: "One Line For Yourself"),
                systemImage: "square.and.pencil"
            )

            Text(prompt)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            ZStack(alignment: .topLeading) {
                if viewModel.journalNote.isEmpty {
                    Text(localized(vi: "Viết nhẹ vài chữ cũng được...", en: "A few gentle words are enough..."))
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary.opacity(0.72))
                        .padding(.horizontal, 13)
                        .padding(.vertical, 17)
                }

                TextEditor(text: $viewModel.journalNote)
                    .frame(minHeight: 118)
                    .padding(8)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
            }
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(HealingTheme.panelBackground(for: colorScheme))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(HealingTheme.cardStroke(for: colorScheme), lineWidth: 0.8)
                    )
            )
        }
    }

    private func storySection(package: DailyPackage) -> some View {
        let favoriteID = "story-\(package.dateKey)"

        return VStack(alignment: .leading, spacing: 11) {
            HStack {
                sectionLabel(
                    title: localized(vi: "Câu chuyện dịu nhẹ", en: "A Gentle Story"),
                    systemImage: "book.closed"
                )

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
                        .frame(width: 36, height: 36)
                }
            }

            Text(package.story.title)
                .font(.headline)

            Text(package.story.body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(HealingTheme.storyTint(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(HealingTheme.cardStroke(for: colorScheme), lineWidth: 0.9)
                )
        )
    }

    private var saveSection: some View {
        Button {
            viewModel.saveCheckin(
                language: selectedLanguage,
                personalization: personalization,
                modelContext: modelContext
            )
        } label: {
            Label(localized(vi: "Lưu nhịp hôm nay", en: "Save Today's Rhythm"), systemImage: "checkmark.seal")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(HealingTheme.primaryAccent(for: colorScheme))
    }

    private func feedbackSection(feedback: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel(
                title: localized(vi: "Lời nhắn cho bạn", en: "A Note For You"),
                systemImage: "sparkles"
            )
            Text(feedback)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func tomorrowSuggestionSection(suggestion: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel(
                title: localized(vi: "Ngày mai đi tiếp", en: "Tomorrow's Next Step"),
                systemImage: "sunrise"
            )
            Text(suggestion)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var safetyNoteSection: some View {
        Text(NextStepEngine.safetyNote(language: selectedLanguage))
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
    }

    private func sectionLabel(title: String, systemImage: String) -> some View {
        Label {
            Text(title)
                .font(.headline)
        } icon: {
            Image(systemName: systemImage)
                .foregroundStyle(HealingTheme.primaryAccent(for: colorScheme))
        }
    }

    private var headerFill: LinearGradient {
        switch colorScheme {
        case .dark:
            return LinearGradient(
                colors: [
                    Color(red: 0.13, green: 0.25, blue: 0.26).opacity(0.94),
                    Color(red: 0.11, green: 0.19, blue: 0.22).opacity(0.98)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                colors: [
                    Color(red: 0.99, green: 0.92, blue: 0.84).opacity(0.94),
                    Color(red: 0.88, green: 0.95, blue: 0.91).opacity(0.94),
                    Color(red: 0.84, green: 0.93, blue: 0.97).opacity(0.88)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var greetingTitle: String {
        switch (dailyEnergyLevel, selectedLanguage) {
        case (.low, .vi):
            return "Hôm nay cứ đi chậm thôi."
        case (.steady, .vi):
            return "Mình giữ một nhịp vừa đủ."
        case (.high, .vi):
            return "Năng lượng đang mở ra."
        case (.low, .en):
            return "Go slowly today."
        case (.steady, .en):
            return "Keep a steady rhythm."
        case (.high, .en):
            return "Your energy is opening up."
        }
    }

    private var greetingSubtitle: String {
        switch (dailyEnergyLevel, selectedLanguage) {
        case (.low, .vi):
            return "Một bước nhỏ vẫn là một cách bạn ở lại với chính mình."
        case (.steady, .vi):
            return "Chọn điều vừa sức, làm gọn, rồi để ngày trôi nhẹ hơn."
        case (.high, .vi):
            return "Thử tiến thêm một chút, nhưng vẫn giữ điểm dừng tử tế."
        case (.low, .en):
            return "One tiny step is still a way of staying with yourself."
        case (.steady, .en):
            return "Choose what feels possible, finish gently, and let the day breathe."
        case (.high, .en):
            return "Move a little further while keeping a kind stopping point."
        }
    }

    private var moodCaption: String {
        switch (viewModel.moodLevel, selectedLanguage) {
        case (1, .vi):
            return "Cần ôm nhẹ"
        case (2, .vi):
            return "Hơi nặng"
        case (3, .vi):
            return "Ở giữa"
        case (4, .vi):
            return "Dễ thở"
        case (5, .vi):
            return "Sáng lên"
        case (1, .en):
            return "Needs care"
        case (2, .en):
            return "A little heavy"
        case (3, .en):
            return "In between"
        case (4, .en):
            return "Breathing easier"
        default:
            return selectedLanguage == .vi ? "Sáng lên" : "Bright"
        }
    }

    private func energyIcon(for energyLevel: DailyEnergyLevel) -> String {
        switch energyLevel {
        case .low:
            return "moon"
        case .steady:
            return "leaf"
        case .high:
            return "sun.max"
        }
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
