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

                List {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(localized(vi: "Chuỗi hiện tại", en: "Current streak"))
                                .font(.headline)
                            Text("\(currentStreak) \(localized(vi: "ngày", en: "days"))")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(localized(vi: "Tiến độ trung bình", en: "Average completion"))
                                    .font(.headline)
                                Text("\(averageCompletion)%")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }

                            Spacer()

                            ZStack {
                                Circle()
                                    .stroke(Color.secondary.opacity(0.20), lineWidth: 7)
                                Circle()
                                    .trim(from: 0, to: CGFloat(max(min(averageCompletion, 100), 0)) / 100)
                                    .stroke(
                                        HealingTheme.primaryAccent(for: colorScheme),
                                        style: StrokeStyle(lineWidth: 7, lineCap: .round)
                                    )
                                    .rotationEffect(.degrees(-90))

                                Text("\(averageCompletion)%")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                            .frame(width: 52, height: 52)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Section(localized(vi: "Tâm trạng", en: "Mood")) {
                        MoodPebbleRow(values: moodPreviewValues, size: 34)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 2)
                    }

                    Section(localized(vi: "Lịch sử", en: "History")) {
                        if checkins.isEmpty {
                            Text(localized(vi: "Chưa có bản ghi check-in.", en: "No check-ins yet."))
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(checkins) { record in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(record.dateKey)
                                        .font(.headline)
                                    Text("\(localized(vi: "Tiến độ", en: "Completion")): \(record.completionPercent)%")
                                        .font(.subheadline)
                                    Text("\(localized(vi: "Tâm trạng", en: "Mood")): \(record.moodLevel)")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listRowBackground(HealingTheme.cardBackground(for: colorScheme))
            }
            .navigationTitle(localized(vi: "Tiến trình", en: "Progress"))
            .tint(HealingTheme.primaryAccent(for: colorScheme))
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

    private var moodPreviewValues: [Int] {
        let values = checkins.prefix(5).map(\.moodLevel)
        if values.isEmpty { return [2, 3, 3, 4, 5] }
        if values.count >= 5 { return values }
        return values + Array(repeating: 3, count: 5 - values.count)
    }

    private func localized(vi: String, en: String) -> String {
        selectedLanguage == .vi ? vi : en
    }
}
