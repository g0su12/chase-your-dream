import Foundation
import SwiftData

enum PersistenceController {
    static let shared: ModelContainer = {
        let schema = Schema([
            DailyCheckinRecord.self,
            FavoriteRecord.self,
            MoodJournalEntry.self
        ])

        do {
            let cloudConfiguration = ModelConfiguration(
                schema: schema,
                cloudKitDatabase: .automatic
            )
            return try ModelContainer(for: schema, configurations: [cloudConfiguration])
        } catch {
            do {
                let localConfiguration = ModelConfiguration(schema: schema)
                return try ModelContainer(for: schema, configurations: [localConfiguration])
            } catch {
                fatalError("Unable to create model container: \(error)")
            }
        }
    }()
}
