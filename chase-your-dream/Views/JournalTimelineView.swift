import SwiftData
import SwiftUI

struct JournalTimelineView: View {
    @Environment(\.colorScheme) private var colorScheme

    @Query(sort: \MoodJournalEntry.createdAt, order: .reverse) private var entries: [MoodJournalEntry]
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
                    if entries.isEmpty {
                        Text(localized(vi: "Chưa có ghi chú mood journal.", en: "No mood journal entries yet."))
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(entries) { entry in
                            HStack(alignment: .top, spacing: 12) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(entry.dateKey)
                                        .font(.headline)

                                    Text(entry.prompt)
                                        .font(.subheadline)

                                    if !entry.note.isEmpty {
                                        Text(entry.note)
                                            .font(.body)
                                    }
                                }

                                Spacer(minLength: 0)

                                MoodBadgeIcon(mood: entry.moodLevel, size: 42)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listRowBackground(HealingTheme.cardBackground(for: colorScheme))
            }
            .navigationTitle(localized(vi: "Nhật ký cảm xúc", en: "Mood journal"))
            .tint(HealingTheme.primaryAccent(for: colorScheme))
        }
    }

    private func localized(vi: String, en: String) -> String {
        selectedLanguage == .vi ? vi : en
    }
}
