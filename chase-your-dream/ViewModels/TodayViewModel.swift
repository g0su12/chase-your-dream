import Combine
import Foundation
import SwiftData

struct PreviousCheckinSummary {
    let dateKey: String
    let completionPercent: Int
    let feedback: String
}

@MainActor
final class TodayViewModel: ObservableObject {
    @Published var selectedDate: Date = .now
    @Published var dailyPackage: DailyPackage?
    @Published var completionPercent: Double = 0
    @Published var moodLevel: Int = 3
    @Published var journalNote: String = ""
    @Published var completedActionIDs: Set<String> = []
    @Published var latestFeedback: String?
    @Published var tomorrowSuggestion: String?
    @Published var previousSummary: PreviousCheckinSummary?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: DailyContentServicing

    init(service: DailyContentServicing) {
        self.service = service
    }

    func load(language: AppLanguage, modelContext: ModelContext) async {
        isLoading = true
        errorMessage = nil

        do {
            let package = try await service.fetchDailyPackage(for: selectedDate, language: language)
            dailyPackage = package
            hydrateFromCurrentCheckin(dateKey: package.dateKey, modelContext: modelContext)
            loadPreviousSummary(baseDate: selectedDate, language: language, modelContext: modelContext)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func toggleAction(_ actionID: String) {
        if completedActionIDs.contains(actionID) {
            completedActionIDs.remove(actionID)
        } else {
            completedActionIDs.insert(actionID)
        }
    }

    func saveCheckin(language: AppLanguage, modelContext: ModelContext) {
        guard let package = dailyPackage else { return }

        do {
            let record = try findOrCreateCheckin(dateKey: package.dateKey, modelContext: modelContext)
            record.completedActionIds = Array(completedActionIDs).sorted()
            record.completionPercent = Int(completionPercent)
            record.moodLevel = moodLevel
            record.journalNote = journalNote
            record.updatedAt = .now

            let journal = try findOrCreateJournal(dateKey: package.dateKey, prompt: package.reflectionPrompt, modelContext: modelContext)
            journal.note = journalNote
            journal.moodLevel = moodLevel
            journal.createdAt = .now

            try modelContext.save()

            latestFeedback = MotivationEngine.feedback(
                completionPercent: Int(completionPercent),
                moodLevel: moodLevel,
                language: language
            )

            tomorrowSuggestion = NextStepEngine.tomorrowSuggestion(
                completionPercent: Int(completionPercent),
                moodLevel: moodLevel,
                language: language
            )

            loadPreviousSummary(baseDate: selectedDate, language: language, modelContext: modelContext)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func hydrateFromCurrentCheckin(dateKey: String, modelContext: ModelContext) {
        do {
            let descriptor = FetchDescriptor<DailyCheckinRecord>(
                predicate: #Predicate { $0.dateKey == dateKey }
            )

            if let record = try modelContext.fetch(descriptor).first {
                completedActionIDs = Set(record.completedActionIds)
                completionPercent = Double(record.completionPercent)
                moodLevel = record.moodLevel
                journalNote = record.journalNote
                latestFeedback = MotivationEngine.feedback(
                    completionPercent: record.completionPercent,
                    moodLevel: record.moodLevel,
                    language: dailyPackage?.locale ?? .vi
                )
                tomorrowSuggestion = NextStepEngine.tomorrowSuggestion(
                    completionPercent: record.completionPercent,
                    moodLevel: record.moodLevel,
                    language: dailyPackage?.locale ?? .vi
                )
            } else {
                completedActionIDs = []
                completionPercent = 0
                moodLevel = 3
                journalNote = ""
                latestFeedback = nil
                tomorrowSuggestion = nil
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadPreviousSummary(baseDate: Date, language: AppLanguage, modelContext: ModelContext) {
        guard let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: baseDate) else {
            previousSummary = nil
            return
        }

        let previousDateKey = DayKeyFormatter.key(for: previousDate)

        do {
            let descriptor = FetchDescriptor<DailyCheckinRecord>(
                predicate: #Predicate { $0.dateKey == previousDateKey }
            )

            guard let previous = try modelContext.fetch(descriptor).first else {
                previousSummary = nil
                return
            }

            previousSummary = PreviousCheckinSummary(
                dateKey: previousDateKey,
                completionPercent: previous.completionPercent,
                feedback: MotivationEngine.feedback(
                    completionPercent: previous.completionPercent,
                    moodLevel: previous.moodLevel,
                    language: language
                )
            )
        } catch {
            errorMessage = error.localizedDescription
            previousSummary = nil
        }
    }

    private func findOrCreateCheckin(dateKey: String, modelContext: ModelContext) throws -> DailyCheckinRecord {
        let descriptor = FetchDescriptor<DailyCheckinRecord>(
            predicate: #Predicate { $0.dateKey == dateKey }
        )

        if let existing = try modelContext.fetch(descriptor).first {
            return existing
        }

        let record = DailyCheckinRecord(dateKey: dateKey)
        modelContext.insert(record)
        return record
    }

    private func findOrCreateJournal(dateKey: String, prompt: String, modelContext: ModelContext) throws -> MoodJournalEntry {
        let descriptor = FetchDescriptor<MoodJournalEntry>(
            predicate: #Predicate { $0.dateKey == dateKey }
        )

        if let existing = try modelContext.fetch(descriptor).first {
            existing.prompt = prompt
            return existing
        }

        let journal = MoodJournalEntry(
            dateKey: dateKey,
            prompt: prompt,
            note: "",
            moodLevel: 3
        )
        modelContext.insert(journal)
        return journal
    }
}
