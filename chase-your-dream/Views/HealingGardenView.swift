import Foundation
import SwiftData
import SwiftUI

struct HealingGardenView: View {
    @Environment(\.colorScheme) private var colorScheme

    @Query(sort: \DailyCheckinRecord.updatedAt, order: .reverse) private var checkins: [DailyCheckinRecord]
    @AppStorage(AppStorageKeys.selectedLanguage) private var selectedLanguageRaw: String = AppLanguage.vi.rawValue

    private var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: selectedLanguageRaw) ?? .vi
    }

    private var gardenRecords: [DailyCheckinRecord] {
        Array(Array(checkins.prefix(16)).reversed())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                HealingTheme.screenBackground(for: colorScheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        gardenHeader

                        animatedGardenCanvas

                        if checkins.isEmpty {
                            emptyState
                                .healingCard(colorScheme: colorScheme)
                        } else {
                            gardenInsight
                                .healingCard(colorScheme: colorScheme, tint: HealingTheme.suggestionTint(for: colorScheme))

                            seedHistory
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 22)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(localized(vi: "Vườn", en: "Garden"))
            .navigationBarTitleDisplayMode(.inline)
            .tint(HealingTheme.primaryAccent(for: colorScheme))
        }
    }

    private var gardenHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 7) {
                    Text(localized(vi: "Vườn cảm xúc của bạn", en: "Your feeling garden"))
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(headerSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                SunDoodleIllustration()
                    .scaleEffect(0.78)
                    .opacity(colorScheme == .dark ? 0.42 : 0.72)
                    .accessibilityHidden(true)
            }

            HStack(spacing: 10) {
                gardenStat(
                    value: "\(checkins.count)",
                    label: localized(vi: "hạt đã gieo", en: "seeds planted"),
                    icon: "leaf"
                )

                gardenStat(
                    value: "\(lowEnergyWins)",
                    label: localized(vi: "giọt sương", en: "dew drops"),
                    icon: "drop"
                )
            }
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

    private func gardenStat(value: String, label: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(HealingTheme.primaryAccent(for: colorScheme))

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.headline.weight(.bold))
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .fill(HealingTheme.panelBackground(for: colorScheme))
        )
    }

    private var animatedGardenCanvas: some View {
        GeometryReader { proxy in
            ZStack {
                gardenBackground

                WaveDoodleIllustration()
                    .scaleEffect(2.0)
                    .opacity(colorScheme == .dark ? 0.12 : 0.26)
                    .position(x: proxy.size.width * 0.78, y: proxy.size.height * 0.18)
                    .accessibilityHidden(true)

                if gardenRecords.isEmpty {
                    emptyGardenSprout
                        .position(x: proxy.size.width * 0.50, y: proxy.size.height * 0.61)
                } else {
                    ForEach(Array(gardenRecords.enumerated()), id: \.element.dateKey) { index, record in
                        GardenSproutView(
                            record: record,
                            index: index,
                            language: selectedLanguage,
                            colorScheme: colorScheme
                        )
                        .position(
                            x: proxy.size.width * gardenPosition(for: index).x,
                            y: proxy.size.height * gardenPosition(for: index).y
                        )
                    }
                }
            }
        }
        .frame(height: 360)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
    }

    private var gardenBackground: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: colorScheme == .dark
                            ? [
                                Color(red: 0.07, green: 0.18, blue: 0.20),
                                Color(red: 0.10, green: 0.25, blue: 0.22),
                                Color(red: 0.12, green: 0.18, blue: 0.16)
                            ]
                            : [
                                Color(red: 0.85, green: 0.94, blue: 0.97),
                                Color(red: 0.90, green: 0.96, blue: 0.88),
                                Color(red: 0.96, green: 0.91, blue: 0.80)
                            ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.44, green: 0.62, blue: 0.44).opacity(colorScheme == .dark ? 0.32 : 0.20),
                            Color(red: 0.61, green: 0.74, blue: 0.50).opacity(colorScheme == .dark ? 0.18 : 0.30)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 96)
                .padding(10)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(HealingTheme.cardStroke(for: colorScheme), lineWidth: 1)
        )
    }

    private var emptyGardenSprout: some View {
        VStack(spacing: 10) {
            MoodSceneIcon(mood: 3, size: 70, isActive: true, isBreathing: true)

            Text(localized(vi: "Lưu check-in đầu tiên để gieo hạt.", en: "Save your first check-in to plant a seed."))
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(width: 180)
        }
    }

    private var gardenInsight: some View {
        VStack(alignment: .leading, spacing: 9) {
            sectionLabel(
                title: localized(vi: "Vườn đang kể gì?", en: "What the garden says"),
                systemImage: "sparkles"
            )

            Text(primaryInsight)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var seedHistory: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel(
                title: localized(vi: "Những hạt gần đây", en: "Recent seeds"),
                systemImage: "calendar"
            )

            ForEach(checkins.prefix(7)) { record in
                seedRow(record: record)
            }
        }
    }

    private func seedRow(record: DailyCheckinRecord) -> some View {
        HStack(alignment: .top, spacing: 12) {
            MoodSceneIcon(
                mood: record.moodLevel,
                size: 44,
                isActive: record.completionPercent >= 60,
                isBreathing: record.completionPercent >= 60
            )

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(record.dateKey)
                        .font(.headline)
                    Spacer()
                    Text(record.energyLevel.title(language: selectedLanguage))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(HealingTheme.primaryAccent(for: colorScheme))
                }

                Text(record.primaryGoal.title(language: selectedLanguage))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)

                Text(seedCaption(for: record))
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
                title: localized(vi: "Khu vườn còn yên tĩnh", en: "The garden is quiet"),
                systemImage: "leaf"
            )

            Text(localized(vi: "Mỗi lần lưu check-in sẽ gieo một hạt nhỏ vào đây. Không cần hoàn hảo, chỉ cần quay lại.", en: "Every saved check-in plants a small seed here. No need to be perfect, just come back."))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var lowEnergyWins: Int {
        checkins.filter { $0.energyLevel == .low && $0.completionPercent >= 40 }.count
    }

    private var primaryInsight: String {
        if lowEnergyWins > 0 {
            return localized(
                vi: "Có \(lowEnergyWins) giọt sương trong vườn: những ngày năng lượng thấp nhưng bạn vẫn quay lại. Đó là điều rất đáng thương yêu.",
                en: "There are \(lowEnergyWins) dew drop(s): low-energy days where you still returned. That is quietly worth caring for."
            )
        }

        if checkins.count >= 5 {
            return localized(
                vi: "Khu vườn đã có nhiều hạt nhỏ. Điều quan trọng không phải là ngày nào cũng rực rỡ, mà là bạn vẫn chăm nó.",
                en: "Your garden has several small seeds now. It does not need to bloom every day; it matters that you still tend to it."
            )
        }

        return localized(
            vi: "Khu vườn đang bắt đầu. Cứ để từng check-in là một hạt nhỏ, không phải một bài kiểm tra.",
            en: "The garden is beginning. Let each check-in be a small seed, not a test."
        )
    }

    private var headerSubtitle: String {
        if checkins.isEmpty {
            return localized(
                vi: "Nơi này sẽ không chấm điểm bạn. Nó chỉ giữ lại những lần bạn đã quay về.",
                en: "This place will not score you. It simply keeps the moments when you returned."
            )
        }

        return localized(
            vi: "\(checkins.count) hạt nhỏ đã được gieo. Một số đang nở, một số chỉ đang nghỉ, và cả hai đều ổn.",
            en: "\(checkins.count) small seed(s) planted. Some are blooming, some are resting, and both are okay."
        )
    }

    private func seedCaption(for record: DailyCheckinRecord) -> String {
        if record.energyLevel == .low && record.completionPercent >= 40 {
            return localized(vi: "Một ngày thấp năng lượng nhưng vẫn có mặt.", en: "A low-energy day where you still showed up.")
        }

        if record.completionPercent >= 80 {
            return localized(vi: "Hạt này nở khá sáng.", en: "This seed bloomed brightly.")
        }

        if record.completionPercent >= 40 {
            return localized(vi: "Một mầm nhỏ đang giữ nhịp.", en: "A small sprout keeping rhythm.")
        }

        return localized(vi: "Một hạt yên tĩnh cũng vẫn là một hạt.", en: "A quiet seed is still a seed.")
    }

    private func gardenPosition(for index: Int) -> (x: CGFloat, y: CGFloat) {
        let positions: [(CGFloat, CGFloat)] = [
            (0.16, 0.74), (0.35, 0.64), (0.55, 0.72), (0.76, 0.60),
            (0.24, 0.48), (0.46, 0.42), (0.68, 0.46), (0.84, 0.76),
            (0.12, 0.58), (0.33, 0.80), (0.58, 0.54), (0.78, 0.34),
            (0.20, 0.34), (0.48, 0.82), (0.66, 0.70), (0.88, 0.50)
        ]
        return positions[index % positions.count]
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

private struct GardenSproutView: View {
    let record: DailyCheckinRecord
    let index: Int
    let language: AppLanguage
    let colorScheme: ColorScheme

    var body: some View {
        TimelineView(.animation) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate
            let sway = sin(phase * 1.2 + Double(index) * 0.8) * 5
            let bounce = sin(phase * 1.6 + Double(index)) * 3
            let growth = 0.78 + CGFloat(record.completionPercent) / 220

            VStack(spacing: -2) {
                ZStack(alignment: .topTrailing) {
                    MoodSceneIcon(
                        mood: record.moodLevel,
                        size: 44 + CGFloat(record.completionPercent) / 7,
                        isActive: record.completionPercent >= 50,
                        isBreathing: true
                    )

                    if record.energyLevel == .low && record.completionPercent >= 40 {
                        Circle()
                            .fill(Color(red: 0.63, green: 0.82, blue: 0.92).opacity(0.78))
                            .frame(width: 9, height: 9)
                            .offset(x: 2, y: 2 + bounce)
                    }
                }
                .offset(y: bounce)

                ZStack(alignment: .bottom) {
                    Capsule(style: .continuous)
                        .fill(stemColor)
                        .frame(width: 6, height: 48 * growth)

                    HStack(spacing: 8) {
                        LeafShape()
                            .fill(leafColor.opacity(0.92))
                            .frame(width: 18, height: 28)
                            .rotationEffect(.degrees(-35 + sway * 0.35))

                        LeafShape()
                            .fill(leafColor.opacity(0.82))
                            .frame(width: 16, height: 24)
                            .rotationEffect(.degrees(42 + sway * 0.24))
                    }
                    .offset(y: -16 * growth)
                }
            }
            .scaleEffect(growth)
            .rotationEffect(.degrees(sway))
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.22 : 0.10), radius: 8, x: 0, y: 5)
            .accessibilityLabel(accessibilityLabel)
        }
        .frame(width: 90, height: 140)
    }

    private var stemColor: Color {
        Color(red: 0.42, green: 0.62, blue: 0.42).opacity(colorScheme == .dark ? 0.78 : 0.86)
    }

    private var leafColor: Color {
        switch record.energyLevel {
        case .low:
            return Color(red: 0.54, green: 0.68, blue: 0.70)
        case .steady:
            return Color(red: 0.54, green: 0.74, blue: 0.52)
        case .high:
            return Color(red: 0.72, green: 0.78, blue: 0.43)
        }
    }

    private var accessibilityLabel: String {
        switch language {
        case .vi:
            return "\(record.dateKey), mood \(record.moodLevel), \(record.energyLevel.title(language: language))"
        case .en:
            return "\(record.dateKey), mood \(record.moodLevel), \(record.energyLevel.title(language: language))"
        }
    }
}
