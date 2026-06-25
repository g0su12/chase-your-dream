import Foundation

enum ReminderTimeCodec {
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    static func decode(csv: String) -> [Date] {
        let values = csv
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if values.isEmpty {
            return defaultTimes()
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: .now)

        return values.compactMap { value in
            guard let parsed = formatter.date(from: value) else { return nil }
            let components = calendar.dateComponents([.hour, .minute], from: parsed)
            return calendar.date(bySettingHour: components.hour ?? 8, minute: components.minute ?? 0, second: 0, of: startOfDay)
        }
    }

    static func encode(times: [Date]) -> String {
        let sorted = times.sorted()
        return sorted
            .map { formatter.string(from: $0) }
            .joined(separator: ",")
    }

    static func defaultTimes() -> [Date] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: .now)
        let first = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: startOfDay) ?? .now
        let second = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: startOfDay) ?? .now
        return [first, second]
    }

    static func suggestedNewTime(from existing: [Date]) -> Date {
        let calendar = Calendar.current
        guard let latest = existing.sorted().last else {
            return defaultTimes().first ?? .now
        }

        return calendar.date(byAdding: .hour, value: 3, to: latest) ?? latest
    }
}
