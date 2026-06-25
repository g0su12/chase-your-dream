import SwiftData
import SwiftUI

struct FavoritesListView: View {
    @Environment(\.colorScheme) private var colorScheme

    @Query(sort: \FavoriteRecord.createdAt, order: .reverse) private var favorites: [FavoriteRecord]
    @Environment(\.modelContext) private var modelContext
    @AppStorage(AppStorageKeys.selectedLanguage) private var selectedLanguageRaw: String = AppLanguage.vi.rawValue

    private var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: selectedLanguageRaw) ?? .vi
    }

    private var displayFavorites: [FavoriteRecord] {
        var seen = Set<String>()
        return favorites.filter { item in
            let normalizedID = MockDailyContentService.normalizedFavoriteID(item.id, type: item.type)
            return seen.insert(normalizedID).inserted
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                HealingTheme.screenBackground(for: colorScheme)
                    .ignoresSafeArea()

                List {
                    if displayFavorites.isEmpty {
                        Text(localized(vi: "Bạn chưa có mục yêu thích.", en: "You do not have any favorites yet."))
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(displayFavorites) { item in
                            let localizedContent = localizedContent(for: item)

                            VStack(alignment: .leading, spacing: 6) {
                                Label(
                                    item.type == .quote
                                        ? localized(vi: "Trích dẫn", en: "Quote")
                                        : localized(vi: "Câu chuyện", en: "Story"),
                                    systemImage: item.type == .quote ? "quote.opening" : "book.closed"
                                )
                                .font(.caption)
                                .foregroundStyle(.secondary)

                                Text(localizedContent.contentText)
                                    .font(.headline)

                                if !localizedContent.detailText.isEmpty {
                                    Text(localizedContent.detailText)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                            .overlay(alignment: .bottomTrailing) {
                                LeafCornerIllustration()
                                    .opacity(colorScheme == .dark ? 0.32 : 0.60)
                                    .offset(x: 6, y: 8)
                            }
                        }
                        .onDelete(perform: delete)
                    }
                }
                .scrollContentBackground(.hidden)
                .listRowBackground(HealingTheme.cardBackground(for: colorScheme))
                .listRowSeparator(.hidden)
            }
            .navigationTitle(localized(vi: "Yêu thích", en: "Favorites"))
            .tint(HealingTheme.primaryAccent(for: colorScheme))
        }
    }

    private func delete(at offsets: IndexSet) {
        offsets.map { displayFavorites[$0] }.forEach { selectedItem in
            let normalizedID = MockDailyContentService.normalizedFavoriteID(selectedItem.id, type: selectedItem.type)
            favorites
                .filter { MockDailyContentService.normalizedFavoriteID($0.id, type: $0.type) == normalizedID }
                .forEach(modelContext.delete)
        }

        try? modelContext.save()
    }

    private func localizedContent(for item: FavoriteRecord) -> (contentText: String, detailText: String) {
        MockDailyContentService.localizedFavoriteContent(
            favoriteID: item.id,
            type: item.type,
            language: selectedLanguage
        ) ?? (item.contentText, item.detailText)
    }

    private func localized(vi: String, en: String) -> String {
        selectedLanguage == .vi ? vi : en
    }
}
