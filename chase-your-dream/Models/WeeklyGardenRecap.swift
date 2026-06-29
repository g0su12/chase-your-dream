import Foundation

struct WeeklyGardenDay: Identifiable {
    let date: Date
    let dateKey: String
    let record: DailyCheckinRecord?

    var id: String { dateKey }
    var hasCheckin: Bool { record != nil }

    func weekdayLabel(language: AppLanguage, calendar: Calendar = .current) -> String {
        let weekday = calendar.component(.weekday, from: date)

        switch language {
        case .vi:
            return ["CN", "T2", "T3", "T4", "T5", "T6", "T7"][weekday - 1]
        case .en:
            return ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][weekday - 1]
        }
    }
}

struct WeeklyGardenRecap {
    let startDateKey: String
    let endDateKey: String
    let days: [WeeklyGardenDay]
    let records: [DailyCheckinRecord]

    var isEmpty: Bool {
        records.isEmpty
    }

    var plantedCount: Int {
        records.count
    }

    var lowEnergyReturnCount: Int {
        records.filter { $0.energyLevel == .low && $0.completionPercent >= 40 }.count
    }

    var averageBloom: Int {
        guard !records.isEmpty else { return 0 }
        let total = records.reduce(0) { $0 + $1.completionPercent }
        return Int((Double(total) / Double(records.count)).rounded())
    }

    var dominantMoodLevel: Int {
        guard !records.isEmpty else { return 3 }

        let counts = Dictionary(grouping: records, by: \.moodLevel)
            .mapValues(\.count)

        return counts
            .sorted { lhs, rhs in
                if lhs.value == rhs.value {
                    return lhs.key > rhs.key
                }
                return lhs.value > rhs.value
            }
            .first?.key ?? 3
    }

    var strongestGoal: PersonalGrowthGoal? {
        let goals = records.flatMap(\.goals)
        guard !goals.isEmpty else { return nil }

        let counts = Dictionary(grouping: goals, by: { $0 })
            .mapValues(\.count)

        return counts
            .sorted { lhs, rhs in
                if lhs.value == rhs.value {
                    return lhs.key.rawValue < rhs.key.rawValue
                }
                return lhs.value > rhs.value
            }
            .first?.key
    }

    static func make(
        from records: [DailyCheckinRecord],
        baseDate: Date = .now,
        calendar: Calendar = .current
    ) -> WeeklyGardenRecap {
        let interval = calendar.dateInterval(of: .weekOfYear, for: baseDate)
        let startDate = interval?.start ?? calendar.startOfDay(for: baseDate)
        let endDate = calendar.date(byAdding: .day, value: 6, to: startDate) ?? startDate

        let recordsByKey = Dictionary(uniqueKeysWithValues: records.map { ($0.dateKey, $0) })

        let days = (0..<7).compactMap { offset -> WeeklyGardenDay? in
            guard let date = calendar.date(byAdding: .day, value: offset, to: startDate) else {
                return nil
            }

            let dateKey = DayKeyFormatter.key(for: date)
            return WeeklyGardenDay(
                date: date,
                dateKey: dateKey,
                record: recordsByKey[dateKey]
            )
        }

        let weekDateKeys = Set(days.map(\.dateKey))
        let weekRecords = records
            .filter { weekDateKeys.contains($0.dateKey) }
            .sorted { $0.dateKey < $1.dateKey }

        return WeeklyGardenRecap(
            startDateKey: DayKeyFormatter.key(for: startDate),
            endDateKey: DayKeyFormatter.key(for: endDate),
            days: days,
            records: weekRecords
        )
    }

    func moodTitle(language: AppLanguage) -> String {
        switch (dominantMoodLevel, language) {
        case (1, .vi): return "mưa nhẹ"
        case (2, .vi): return "hơi nặng"
        case (3, .vi): return "ở giữa"
        case (4, .vi): return "dịu hơn"
        case (5, .vi): return "có nắng"
        case (1, .en): return "soft rain"
        case (2, .en): return "a little heavy"
        case (3, .en): return "in the middle"
        case (4, .en): return "lighter"
        default: return language == .vi ? "có nắng" : "sunlit"
        }
    }

    func headline(language: AppLanguage) -> String {
        if isEmpty {
            return language == .vi ? "Tuần này còn đang mở" : "This week is still open"
        }

        if lowEnergyReturnCount >= 2 {
            return language == .vi
                ? "Bạn vẫn quay lại cả khi tuần này hơi nặng."
                : "You kept returning even when the week felt heavy."
        }

        if plantedCount >= 5 {
            return language == .vi
                ? "Tuần này khu vườn được chăm khá đều."
                : "This week, your garden was tended steadily."
        }

        if averageBloom >= 75 {
            return language == .vi
                ? "Có nhiều mầm đã nở sáng trong tuần này."
                : "Several seeds bloomed brightly this week."
        }

        return language == .vi
            ? "Bạn đã gieo \(plantedCount) hạt nhỏ trong tuần này."
            : "You planted \(plantedCount) small seed(s) this week."
    }

    func body(language: AppLanguage) -> String {
        if isEmpty {
            return language == .vi
                ? "Chỉ cần một check-in nhỏ là khu vườn tuần này bắt đầu có dấu vết."
                : "One small check-in is enough for this week's garden to begin."
        }

        let goalText = strongestGoal?.title(language: language)
        switch language {
        case .vi:
            if let goalText {
                return "Mood nổi bật là \(moodTitle(language: language)), mức nở trung bình \(averageBloom)%, và \(goalText.lowercased()) đang là hướng được chăm nhiều nhất."
            }
            return "Mood nổi bật là \(moodTitle(language: language)) và mức nở trung bình \(averageBloom)%."
        case .en:
            if let goalText {
                return "The main mood was \(moodTitle(language: language)), average bloom was \(averageBloom)%, and \(goalText.lowercased()) received the most care."
            }
            return "The main mood was \(moodTitle(language: language)) and average bloom was \(averageBloom)%."
        }
    }

    func todayNudge(language: AppLanguage) -> String {
        if isEmpty {
            return language == .vi
                ? "Tuần này chưa cần bứt tốc. Một hạt nhỏ hôm nay là đủ."
                : "No need to rush this week. One small seed today is enough."
        }

        if lowEnergyReturnCount > 0 {
            return language == .vi
                ? "Tuần này có ngày năng lượng thấp mà bạn vẫn quay lại. Hôm nay cứ đi nhẹ."
                : "This week had a low-energy return. Keep today's step gentle."
        }

        if plantedCount >= 4 {
            return language == .vi
                ? "Tuần này bạn đã quay lại \(plantedCount) lần. Nhịp này đáng được giữ thật mềm."
                : "You have returned \(plantedCount) time(s) this week. Keep the rhythm soft."
        }

        return language == .vi
            ? "Tuần này đã có \(plantedCount) hạt nhỏ. Hôm nay thêm một hạt vừa sức thôi."
            : "This week has \(plantedCount) small seed(s). Add one gentle seed today."
    }
}
