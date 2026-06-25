import Foundation
import SwiftData
import SwiftUI

enum AppLanguage: String, CaseIterable, Codable, Identifiable {
    case vi
    case en

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .vi:
            return "Tiếng Việt"
        case .en:
            return "English"
        }
    }
}

enum AppAppearanceMode: String, CaseIterable, Codable, Identifiable {
    case system
    case dark
    case light

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .dark:
            return .dark
        case .light:
            return .light
        }
    }

    func displayName(language: AppLanguage) -> String {
        switch (self, language) {
        case (.system, .vi):
            return "Hệ thống"
        case (.dark, .vi):
            return "Tối"
        case (.light, .vi):
            return "Sáng"
        case (.system, .en):
            return "System"
        case (.dark, .en):
            return "Dark"
        case (.light, .en):
            return "Light"
        }
    }
}

enum FavoriteContentType: String, Codable {
    case quote
    case story
}

struct Quote: Codable, Hashable {
    let text: String
    let author: String
}

struct Story: Codable, Hashable {
    let title: String
    let body: String
}

struct MicroAction: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    let detail: String
    let recommendedMinutes: Int
}

struct DailyPackage: Codable, Hashable, Identifiable {
    let id: String
    let dateKey: String
    let locale: AppLanguage
    let quote: Quote
    let story: Story
    let reflectionPrompt: String
    let microActions: [MicroAction]
}

@Model
final class DailyCheckinRecord {
    @Attribute(.unique) var dateKey: String
    var completedActionIdsRaw: String
    var completionPercent: Int
    var moodLevel: Int
    var journalNote: String
    var updatedAt: Date

    init(
        dateKey: String,
        completedActionIds: [String] = [],
        completionPercent: Int = 0,
        moodLevel: Int = 3,
        journalNote: String = "",
        updatedAt: Date = .now
    ) {
        self.dateKey = dateKey
        self.completedActionIdsRaw = completedActionIds.joined(separator: ",")
        self.completionPercent = completionPercent
        self.moodLevel = moodLevel
        self.journalNote = journalNote
        self.updatedAt = updatedAt
    }

    var completedActionIds: [String] {
        get {
            completedActionIdsRaw
                .split(separator: ",")
                .map(String.init)
                .filter { !$0.isEmpty }
        }
        set {
            completedActionIdsRaw = newValue.joined(separator: ",")
        }
    }
}

@Model
final class FavoriteRecord {
    @Attribute(.unique) var id: String
    var typeRaw: String
    var contentText: String
    var detailText: String
    var createdAt: Date

    init(
        id: String,
        type: FavoriteContentType,
        contentText: String,
        detailText: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.typeRaw = type.rawValue
        self.contentText = contentText
        self.detailText = detailText
        self.createdAt = createdAt
    }

    var type: FavoriteContentType {
        get { FavoriteContentType(rawValue: typeRaw) ?? .quote }
        set { typeRaw = newValue.rawValue }
    }
}

@Model
final class MoodJournalEntry {
    @Attribute(.unique) var dateKey: String
    var prompt: String
    var note: String
    var moodLevel: Int
    var createdAt: Date

    init(
        dateKey: String,
        prompt: String,
        note: String,
        moodLevel: Int,
        createdAt: Date = .now
    ) {
        self.dateKey = dateKey
        self.prompt = prompt
        self.note = note
        self.moodLevel = moodLevel
        self.createdAt = createdAt
    }
}

enum AppStorageKeys {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let onboardingEmotion = "onboardingEmotion"
    static let selectedLanguage = "selectedLanguage"
    static let selectedAppearance = "selectedAppearance"
    static let reminderTimesCSV = "reminderTimesCSV"
    static let simulateNetworkFailure = "simulateNetworkFailure"
}
