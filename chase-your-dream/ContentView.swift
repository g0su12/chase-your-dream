//
//  ContentView.swift
//  chase-your-dream
//
//  Created by HuyNQ1 on 24/4/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) private var systemColorScheme

    private let dailyService: DailyContentServicing
    @AppStorage(AppStorageKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @AppStorage(AppStorageKeys.selectedLanguage) private var selectedLanguageRaw: String = AppLanguage.vi.rawValue
    @AppStorage(AppStorageKeys.selectedAppearance) private var selectedAppearanceRaw: String = AppAppearanceMode.system.rawValue

    init(dailyService: DailyContentServicing = MockDailyContentService()) {
        self.dailyService = dailyService
    }

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                mainTabView
                    .transition(.opacity)
            } else {
                OnboardingView(language: selectedLanguage) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        hasCompletedOnboarding = true
                    }
                }
                .transition(.opacity)
            }
        }
        .fontDesign(.rounded)
        .tint(HealingTheme.primaryAccent(for: resolvedColorScheme))
        .preferredColorScheme(selectedAppearance.colorScheme)
        .animation(.easeInOut(duration: 0.35), value: hasCompletedOnboarding)
    }

    private var mainTabView: some View {
        TabView {
            TodayView(service: dailyService)
                .tabItem {
                    Label(localized(vi: "Hôm nay", en: "Today"), systemImage: "sun.max")
                }

            HealingGardenView()
                .tabItem {
                    Label(localized(vi: "Vườn", en: "Garden"), systemImage: "leaf")
                }

            FavoritesListView()
                .tabItem {
                    Label(localized(vi: "Yêu thích", en: "Favorites"), systemImage: "star")
                }

            JournalTimelineView()
                .tabItem {
                    Label(localized(vi: "Nhật ký", en: "Journal"), systemImage: "book")
                }

            SettingsScreenView()
                .tabItem {
                    Label(localized(vi: "Cài đặt", en: "Settings"), systemImage: "gearshape")
                }
        }
    }

    private var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: selectedLanguageRaw) ?? .vi
    }

    private var selectedAppearance: AppAppearanceMode {
        AppAppearanceMode(rawValue: selectedAppearanceRaw) ?? .system
    }

    private var resolvedColorScheme: ColorScheme {
        selectedAppearance.colorScheme ?? systemColorScheme
    }

    private func localized(vi: String, en: String) -> String {
        selectedLanguage == .vi ? vi : en
    }
}

#Preview {
    ContentView()
}
