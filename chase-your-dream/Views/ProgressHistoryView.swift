import Foundation
import SwiftData
import SwiftUI

struct ProgressHistoryView: View {
    @Environment(\.colorScheme) private var colorScheme

    @Query(sort: \DailyCheckinRecord.updatedAt, order: .reverse) private var checkins: [DailyCheckinRecord]
    @AppStorage(AppStorageKeys.selectedLanguage) private var selectedLanguageRaw: String = AppLanguage.vi.rawValue

    private var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: selectedLanguageRaw) ?? .vi
    }

    var body: some View {
        NavigationStack {
            ZStack {
                HealingTheme.screenBackground(for: colorScheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        progressHeader

                        if checkins.isEmpty {
                            emptyState
                                .healingCard(colorScheme: colorScheme)
                        } else {
                            metricGrid

                            insightSection
                                .healingCard(colorScheme: colorScheme, tint: HealingTheme.suggestionTint(for: colorScheme))

                            rhythmSection
                                .healingCard(colorScheme: colorScheme)

                            goalSection
                                .healingCard(colorScheme: colorScheme, tint: HealingTheme.successTint(for: colorScheme))

                            historySection
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 22)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(localized(vi: "Tiến trình", en: "Progress"))
            .navigationBarTitleDisplayMode(.inline)
            .tint(HealingTheme.primaryAccent(for: colorScheme))
        }
    }

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 7) {
                    Text(localized(vi: "Bạn vẫn đang quay lại.", en: "You keep coming back."))
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(headerSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                LeafCornerIllustration()
                    .scaleEffect(1.4)
                    .opacity(colorScheme == .dark ? 0.36 : 0.62)
                    .accessibilityHidden(true)
            }

            MoodPebbleRow(values: moodPreviewValues, size: 34)
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
        .shadow(
            color: colorScheme == .dark
                ? Color.black.opacity(0.26)
                : Color(red: 0.50, green: 0.56, blue: 0.48).opacity(0.15),
            radius: 14,
            x: 0,
            y: 8
        )
    }

    private var metricGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 12
        ) {
            metricCard(
                title: localized(vi: "Chuỗi hiện tại", en: "Current streak"),
                value: "\(currentStreak)",
                caption: localized(vi: "ngày quay lại", en: "days returned"),
                systemImage: "sparkles"
            )

            metricCard(
                title: localized(vi: "Tiến độ TB", en: "Average"),
                value: "\(averageCompletion)%",
                caption: localized(vi: "nhịp hoàn thành", en: "completion rhythm"),
                systemImage: "chart.line.uptrend.xyaxis"
            )

            metricCard(
                title: localized(vi: "Ngày khó vẫn làm", en: "Low-energy wins"),
                value: "\(lowEnergyWins)",
                caption: localized(vi: "lần vẫn có mặt", en: "gentle returns"),
                systemImage: "moon"
            )

            metricCard(
                title: localized(vi: "Check-in", en: "Check-ins"),
                value: "\(checkins.count)",
                caption: localized(vi: "dấu mốc nhỏ", en: "small marks"),
                systemImage: "checkmark.seal"
            )
        }
    }

    private func metricCard(title: String, value: String, caption: String, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: systemImage)
                    .font(.headline)
                    .foregroundStyle(HealingTheme.primaryAccent(for: colorScheme))
                Spacer()
            }

            Text(value)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(caption)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 128, alignment: .topLeading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(HealingTheme.cardBackground(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(HealingTheme.cardStroke(for: colorScheme), lineWidth: 0.9)
                )
        )
    }

    private var insightSection: some View {
        VStack(alignment: .leading, spacing: 9) {
            sectionLabel(
                title: localized(vi: "Điều đáng ghi nhận", en: "Worth Noticing"),
                systemImage: "heart.text.square"
            )

            Text(primaryInsight)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var rhythmSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel(
                title: localized(vi: "Nhịp gần đây", en: "Recent Rhythm"),
                systemImage: "waveform.path.ecg"
            )

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(localized(vi: "Tâm trạng", en: "Mood"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(averageMoodLabel)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                MoodPebbleRow(values: moodPreviewValues, size: 36)

                Divider()

                HStack(spacing: 8) {
                    ForEach(DailyEnergyLevel.allCases) { energyLevel in
                        energyPill(
                            energyLevel: energyLevel,
                            count: energyCount(for: energyLevel)
                        )
                    }
                }
            }
        }
    }

    private func energyPill(energyLevel: DailyEnergyLevel, count: Int) -> some View {
        VStack(spacing: 5) {
            Image(systemName: energyIcon(for: energyLevel))
                .font(.subheadline)

            Text(energyLevel.title(language: selectedLanguage))
                .font(.caption.weight(.semibold))
                .lineLimit(1)

            Text("\(count)")
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .fill(count > 0 ? HealingTheme.suggestionTint(for: colorScheme) : HealingTheme.panelBackground(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 17, style: .continuous)
                        .stroke(HealingTheme.cardStroke(for: colorScheme), lineWidth: 0.8)
                )
        )
        .foregroundStyle(count > 0 ? HealingTheme.primaryAccent(for: colorScheme) : .secondary)
    }

    private var goalSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(
                title: localized(vi: "Mục tiêu đang nâng đỡ bạn", en: "Goal That Supports You"),
                systemImage: strongestGoal?.systemImage ?? "leaf"
            )

            if let strongestGoal {
                Text(
                    localized(
                        vi: "\(strongestGoal.title(language: selectedLanguage)) đang là hướng giúp bạn giữ nhịp tốt nhất, với tiến độ trung bình \(averageCompletion(for: strongestGoal) ?? 0)%.",
                        en: "\(strongestGoal.title(language: selectedLanguage)) is currently your steadiest direction, averaging \(averageCompletion(for: strongestGoal) ?? 0)% completion."
                    )
                )
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
            } else {
                Text(localized(vi: "Khi bạn check-in thêm vài ngày, app sẽ tìm ra mục tiêu đang nâng đỡ bạn nhiều nhất.", en: "After a few more check-ins, the app will find which goal supports your rhythm most."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel(
                title: localized(vi: "Những dấu mốc nhỏ", en: "Small Milestones"),
                systemImage: "calendar"
            )

            ForEach(checkins.prefix(8)) { record in
                historyRow(record: record)
            }
        }
    }

    private func historyRow(record: DailyCheckinRecord) -> some View {
        HStack(alignment: .top, spacing: 12) {
            MoodBadgeIcon(mood: record.moodLevel, size: 42)

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(record.dateKey)
                        .font(.headline)

                    Spacer()

                    Text("\(record.completionPercent)%")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(HealingTheme.primaryAccent(for: colorScheme))
                }

                Text(record.primaryGoal.title(language: selectedLanguage))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Label(record.energyLevel.title(language: selectedLanguage), systemImage: energyIcon(for: record.energyLevel))
                    Label(localized(vi: "Mood \(record.moodLevel)", en: "Mood \(record.moodLevel)"), systemImage: "face.smiling")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(HealingTheme.cardBackground(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(HealingTheme.cardStroke(for: colorScheme), lineWidth: 0.8)
                )
        )
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(
                title: localized(vi: "Chưa có dấu mốc", en: "No Marks Yet"),
                systemImage: "leaf"
            )

            Text(localized(vi: "Hãy lưu check-in đầu tiên ở màn Hôm nay. Chỉ một dòng nhỏ cũng đủ để bắt đầu nhìn thấy nhịp của mình.", en: "Save your first check-in from Today. Even one small line is enough to start seeing your rhythm."))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var currentStreak: Int {
        let completedDateKeys = Set(
            checkins
                .filter { $0.completionPercent >= 80 }
                .map(\.dateKey)
        )

        var streak = 0
        var cursorDate = Calendar.current.startOfDay(for: .now)

        while completedDateKeys.contains(DayKeyFormatter.key(for: cursorDate)) {
            streak += 1
            guard let previous = Calendar.current.date(byAdding: .day, value: -1, to: cursorDate) else {
                break
            }
            cursorDate = previous
        }

        return streak
    }

    private var averageCompletion: Int {
        guard !checkins.isEmpty else { return 0 }
        let total = checkins.reduce(0) { $0 + $1.completionPercent }
        return total / checkins.count
    }

    private var lowEnergyWins: Int {
        checkins.filter { $0.energyLevel == .low && $0.completionPercent >= 40 }.count
    }

    private var moodPreviewValues: [Int] {
        let values = checkins.prefix(7).map(\.moodLevel)
        if values.isEmpty { return [2, 3, 3, 4, 5] }
        if values.count >= 5 { return values }
        return values + Array(repeating: 3, count: 5 - values.count)
    }

    private var averageMood: Double {
        guard !checkins.isEmpty else { return 3 }
        let total = checkins.reduce(0) { $0 + $1.moodLevel }
        return Double(total) / Double(checkins.count)
    }

    private var averageMoodLabel: String {
        let rounded = String(format: "%.1f", averageMood)
        return localized(vi: "trung bình \(rounded)/5", en: "average \(rounded)/5")
    }

    private var primaryInsight: String {
        if checkins.isEmpty {
            return localized(vi: "Bạn chưa cần chứng minh gì cả. Một check-in đầu tiên là đủ để mở nhịp.", en: "You do not need to prove anything. One first check-in is enough to begin.")
        }

        if lowEnergyWins > 0 {
            return localized(
                vi: "Bạn đã có \(lowEnergyWins) ngày năng lượng thấp nhưng vẫn quay lại. Đó là tiến bộ rất thật, không cần ồn ào.",
                en: "You have \(lowEnergyWins) low-energy day(s) where you still came back. That is quiet, real progress."
            )
        }

        if currentStreak > 0 {
            return localized(
                vi: "Bạn đang giữ chuỗi \(currentStreak) ngày hoàn thành tốt. Hãy để nhịp này tiếp tục nhẹ nhàng, không cần ép quá sức.",
                en: "You are holding a \(currentStreak)-day strong streak. Let it continue gently, without forcing it."
            )
        }

        if averageCompletion >= 60 {
            return localized(
                vi: "Tiến độ trung bình của bạn đang khá vững. Điều đáng quý nhất là bạn vẫn có mặt với chính mình.",
                en: "Your average progress is steady. The most meaningful part is that you are still showing up for yourself."
            )
        }

        return localized(
            vi: "Mỗi lần check-in là một lần bạn quay về. Hôm nay chỉ cần giữ một bước nhỏ là đủ.",
            en: "Every check-in is a return. Today, one small step is enough."
        )
    }

    private var headerSubtitle: String {
        if checkins.isEmpty {
            return localized(
                vi: "Khi bạn lưu những check-in đầu tiên, nơi này sẽ kể lại hành trình bằng giọng dịu hơn.",
                en: "Once you save your first check-ins, this place will reflect your path back in a gentler voice."
            )
        }

        return localized(
            vi: "\(checkins.count) lần check-in, \(averageCompletion)% tiến độ trung bình, và nhiều dấu hiệu nhỏ cho thấy bạn vẫn đang đi tiếp.",
            en: "\(checkins.count) check-ins, \(averageCompletion)% average completion, and quiet signs that you are still moving."
        )
    }

    private var strongestGoal: PersonalGrowthGoal? {
        PersonalGrowthGoal.allCases
            .compactMap { goal -> (goal: PersonalGrowthGoal, average: Int)? in
                guard let average = averageCompletion(for: goal) else { return nil }
                return (goal, average)
            }
            .max { $0.average < $1.average }?
            .goal
    }

    private func averageCompletion(for goal: PersonalGrowthGoal) -> Int? {
        let matchingRecords = checkins.filter { $0.goals.contains(goal) }
        guard !matchingRecords.isEmpty else { return nil }
        let total = matchingRecords.reduce(0) { $0 + $1.completionPercent }
        return total / matchingRecords.count
    }

    private func energyCount(for energyLevel: DailyEnergyLevel) -> Int {
        checkins.filter { $0.energyLevel == energyLevel }.count
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
                    Color(red: 0.12, green: 0.24, blue: 0.25).opacity(0.94),
                    Color(red: 0.08, green: 0.16, blue: 0.20).opacity(0.98)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                colors: [
                    Color(red: 0.92, green: 0.97, blue: 0.91).opacity(0.94),
                    Color(red: 0.85, green: 0.93, blue: 0.97).opacity(0.92),
                    Color(red: 0.99, green: 0.91, blue: 0.84).opacity(0.88)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private func localized(vi: String, en: String) -> String {
        selectedLanguage == .vi ? vi : en
    }
}
