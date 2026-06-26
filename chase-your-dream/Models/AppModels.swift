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

enum PersonalGrowthGoal: String, CaseIterable, Codable, Hashable, Identifiable {
    case health
    case learning
    case work
    case calm
    case discipline

    var id: String { rawValue }

    static let defaultSelection: [PersonalGrowthGoal] = [.calm, .discipline]

    static var defaultSelectionCSV: String {
        encode(defaultSelection)
    }

    var systemImage: String {
        switch self {
        case .health:
            return "heart"
        case .learning:
            return "book"
        case .work:
            return "briefcase"
        case .calm:
            return "leaf"
        case .discipline:
            return "target"
        }
    }

    func title(language: AppLanguage) -> String {
        switch (self, language) {
        case (.health, .vi):
            return "Sức khỏe"
        case (.learning, .vi):
            return "Học tập"
        case (.work, .vi):
            return "Công việc"
        case (.calm, .vi):
            return "Tinh thần"
        case (.discipline, .vi):
            return "Kỷ luật"
        case (.health, .en):
            return "Health"
        case (.learning, .en):
            return "Learning"
        case (.work, .en):
            return "Work"
        case (.calm, .en):
            return "Mind"
        case (.discipline, .en):
            return "Discipline"
        }
    }

    func detail(language: AppLanguage) -> String {
        switch (self, language) {
        case (.health, .vi):
            return "Năng lượng, vận động nhẹ và chăm sóc cơ thể."
        case (.learning, .vi):
            return "Đọc, học và tích lũy kiến thức theo nhịp nhỏ."
        case (.work, .vi):
            return "Tập trung, hoàn thành việc quan trọng và giảm phân tán."
        case (.calm, .vi):
            return "Bình tĩnh, hồi phục và chăm sóc cảm xúc."
        case (.discipline, .vi):
            return "Giữ lời hứa nhỏ với bản thân mỗi ngày."
        case (.health, .en):
            return "Energy, light movement, and body care."
        case (.learning, .en):
            return "Reading, studying, and steady knowledge building."
        case (.work, .en):
            return "Focus, meaningful output, and less distraction."
        case (.calm, .en):
            return "Calm, recovery, and emotional care."
        case (.discipline, .en):
            return "Keeping small promises to yourself."
        }
    }

    static func decode(csv: String) -> [PersonalGrowthGoal] {
        let values = csv
            .split(separator: ",")
            .compactMap { value in
                PersonalGrowthGoal(rawValue: value.trimmingCharacters(in: .whitespacesAndNewlines))
            }

        let uniqueValues = values.reduce(into: [PersonalGrowthGoal]()) { result, goal in
            if !result.contains(goal) {
                result.append(goal)
            }
        }

        return uniqueValues.isEmpty ? defaultSelection : uniqueValues
    }

    static func encode(_ goals: [PersonalGrowthGoal]) -> String {
        let selected = Set(goals)
        let ordered = allCases.filter { selected.contains($0) }
        let resolved = ordered.isEmpty ? defaultSelection : ordered

        return resolved
            .map(\.rawValue)
            .joined(separator: ",")
    }
}

enum DailyEnergyLevel: String, CaseIterable, Codable, Hashable, Identifiable {
    case low
    case steady
    case high

    var id: String { rawValue }

    func title(language: AppLanguage) -> String {
        switch (self, language) {
        case (.low, .vi):
            return "Thấp"
        case (.steady, .vi):
            return "Vừa"
        case (.high, .vi):
            return "Cao"
        case (.low, .en):
            return "Low"
        case (.steady, .en):
            return "Steady"
        case (.high, .en):
            return "High"
        }
    }

    func detail(language: AppLanguage) -> String {
        switch (self, language) {
        case (.low, .vi):
            return "Ưu tiên hồi phục, hành động ngắn và ít ma sát."
        case (.steady, .vi):
            return "Giữ nhịp đều, chọn việc vừa sức nhưng có tiến triển."
        case (.high, .vi):
            return "Có thể tăng thử thách nhẹ mà vẫn giữ nhịp bền."
        case (.low, .en):
            return "Prioritize recovery, short actions, and low friction."
        case (.steady, .en):
            return "Keep a steady rhythm with manageable progress."
        case (.high, .en):
            return "Add a gentle challenge while keeping the pace sustainable."
        }
    }
}

struct DailyPersonalization: Codable, Hashable {
    let goals: [PersonalGrowthGoal]
    let energyLevel: DailyEnergyLevel

    init(goals: [PersonalGrowthGoal], energyLevel: DailyEnergyLevel) {
        self.goals = goals.isEmpty ? PersonalGrowthGoal.defaultSelection : goals
        self.energyLevel = energyLevel
    }

    static let defaultValue = DailyPersonalization(
        goals: PersonalGrowthGoal.defaultSelection,
        energyLevel: .steady
    )

    static func fromStorage(goalsCSV: String, energyLevelRaw: String) -> DailyPersonalization {
        DailyPersonalization(
            goals: PersonalGrowthGoal.decode(csv: goalsCSV),
            energyLevel: DailyEnergyLevel(rawValue: energyLevelRaw) ?? .steady
        )
    }

    var cacheKey: String {
        let goalsKey = PersonalGrowthGoal.encode(goals)
            .replacingOccurrences(of: ",", with: ".")
        return "\(energyLevel.rawValue)-\(goalsKey)"
    }

    var primaryGoal: PersonalGrowthGoal {
        goals.first ?? PersonalGrowthGoal.defaultSelection[0]
    }

    func rotatingGoal(dayIndex: Int) -> PersonalGrowthGoal {
        let resolvedGoals = goals.isEmpty ? PersonalGrowthGoal.defaultSelection : goals
        return resolvedGoals[dayIndex % resolvedGoals.count]
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
    let personalizationKey: String
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
    var energyLevelRaw: String = DailyEnergyLevel.steady.rawValue
    var goalsRaw: String = PersonalGrowthGoal.defaultSelectionCSV
    var journalNote: String
    var updatedAt: Date

    init(
        dateKey: String,
        completedActionIds: [String] = [],
        completionPercent: Int = 0,
        moodLevel: Int = 3,
        energyLevel: DailyEnergyLevel = .steady,
        goals: [PersonalGrowthGoal] = PersonalGrowthGoal.defaultSelection,
        journalNote: String = "",
        updatedAt: Date = .now
    ) {
        self.dateKey = dateKey
        self.completedActionIdsRaw = completedActionIds.joined(separator: ",")
        self.completionPercent = completionPercent
        self.moodLevel = moodLevel
        self.energyLevelRaw = energyLevel.rawValue
        self.goalsRaw = PersonalGrowthGoal.encode(goals)
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

    var energyLevel: DailyEnergyLevel {
        get { DailyEnergyLevel(rawValue: energyLevelRaw) ?? .steady }
        set { energyLevelRaw = newValue.rawValue }
    }

    var goals: [PersonalGrowthGoal] {
        get { PersonalGrowthGoal.decode(csv: goalsRaw) }
        set { goalsRaw = PersonalGrowthGoal.encode(newValue) }
    }

    var primaryGoal: PersonalGrowthGoal {
        goals.first ?? PersonalGrowthGoal.defaultSelection[0]
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
    static let selectedGoalsCSV = "selectedGoalsCSV"
    static let dailyEnergyLevel = "dailyEnergyLevel"
    static let reminderTimesCSV = "reminderTimesCSV"
    static let simulateNetworkFailure = "simulateNetworkFailure"
}
