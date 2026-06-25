import Foundation

protocol DailyContentServicing {
    func fetchDailyPackage(for date: Date, language: AppLanguage) async throws -> DailyPackage
}

enum DailyContentServiceError: LocalizedError {
    case noCachedPackage

    var errorDescription: String? {
        switch self {
        case .noCachedPackage:
            return "No cached data available yet."
        }
    }
}

final class DailyPackageCacheStore {
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func save(_ package: DailyPackage) {
        let key = cacheKey(dateKey: package.dateKey, language: package.locale)
        guard let data = try? encoder.encode(package) else { return }
        defaults.set(data, forKey: key)
    }

    func load(dateKey: String, language: AppLanguage) -> DailyPackage? {
        let key = cacheKey(dateKey: dateKey, language: language)
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(DailyPackage.self, from: data)
    }

    private func cacheKey(dateKey: String, language: AppLanguage) -> String {
        "daily_package_\(dateKey)_\(language.rawValue)"
    }
}

final class MockDailyContentService: DailyContentServicing {
    private let cacheStore: DailyPackageCacheStore
    private let defaults: UserDefaults

    init(
        cacheStore: DailyPackageCacheStore = DailyPackageCacheStore(),
        defaults: UserDefaults = .standard
    ) {
        self.cacheStore = cacheStore
        self.defaults = defaults
    }

    func fetchDailyPackage(for date: Date, language: AppLanguage) async throws -> DailyPackage {
        let dateKey = DayKeyFormatter.key(for: date)

        do {
            try await Task.sleep(nanoseconds: 250_000_000)

            if defaults.bool(forKey: AppStorageKeys.simulateNetworkFailure) {
                throw URLError(.notConnectedToInternet)
            }

            let package = makePackage(for: date, dateKey: dateKey, language: language)
            cacheStore.save(package)
            return package
        } catch {
            if let cached = cacheStore.load(dateKey: dateKey, language: language) {
                return cached
            }
            throw DailyContentServiceError.noCachedPackage
        }
    }

    static func normalizedFavoriteID(_ id: String, type: FavoriteContentType? = nil) -> String {
        let resolvedType: FavoriteContentType?
        if let type {
            resolvedType = type
        } else if id.hasPrefix("quote-") {
            resolvedType = .quote
        } else if id.hasPrefix("story-") {
            resolvedType = .story
        } else {
            resolvedType = nil
        }

        guard let resolvedType, let dateKey = extractDateKey(from: id, type: resolvedType) else {
            return id
        }

        return "\(resolvedType.rawValue)-\(dateKey)"
    }

    static func extractDateKey(from favoriteID: String, type: FavoriteContentType) -> String? {
        let prefix = "\(type.rawValue)-"
        guard favoriteID.hasPrefix(prefix) else { return nil }

        var remainder = String(favoriteID.dropFirst(prefix.count))
        if remainder.hasSuffix("-vi") || remainder.hasSuffix("-en") {
            remainder.removeLast(3)
        }

        return remainder.isEmpty ? nil : remainder
    }

    static func localizedFavoriteContent(
        favoriteID: String,
        type: FavoriteContentType,
        language: AppLanguage
    ) -> (contentText: String, detailText: String)? {
        guard
            let dateKey = extractDateKey(from: favoriteID, type: type),
            let date = DayKeyFormatter.date(from: dateKey)
        else {
            return nil
        }

        let service = MockDailyContentService()
        let package = service.makePackage(for: date, dateKey: dateKey, language: language)

        switch type {
        case .quote:
            return (package.quote.text, package.quote.author)
        case .story:
            return (package.story.title, package.story.body)
        }
    }

    private func makePackage(for date: Date, dateKey: String, language: AppLanguage) -> DailyPackage {
        let dayIndex = max((Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1) - 1, 0)

        let quote = pickQuote(dayIndex: dayIndex, language: language)
        let story = pickStory(dayIndex: dayIndex, language: language)
        let reflectionPrompt = pickPrompt(dayIndex: dayIndex, language: language)
        let actions = pickActions(dayIndex: dayIndex, language: language)

        return DailyPackage(
            id: "\(dateKey)-\(language.rawValue)",
            dateKey: dateKey,
            locale: language,
            quote: quote,
            story: story,
            reflectionPrompt: reflectionPrompt,
            microActions: actions
        )
    }

    private func pickQuote(dayIndex: Int, language: AppLanguage) -> Quote {
        let viQuotes: [Quote] = [
            Quote(text: "Mỗi ngày tiến một chút vẫn tốt hơn đứng yên.", author: "Động lực mỗi ngày"),
            Quote(text: "Bạn không cần hoàn hảo, bạn chỉ cần bắt đầu.", author: "Động lực mỗi ngày"),
            Quote(text: "Nhịp sống lành mạnh được xây từ hành động nhỏ.", author: "Động lực mỗi ngày"),
            Quote(text: "Khi tâm trí rối, hãy quay về với một bước đơn giản.", author: "Động lực mỗi ngày"),
            Quote(text: "Tiến bộ chậm vẫn là tiến bộ thật.", author: "Động lực mỗi ngày")
        ]

        let enQuotes: [Quote] = [
            Quote(text: "A small step today is still forward progress.", author: "Daily Motivation"),
            Quote(text: "You do not need perfect. You need a start.", author: "Daily Motivation"),
            Quote(text: "Healthy rhythm is built from tiny actions.", author: "Daily Motivation"),
            Quote(text: "When life feels blurry, return to one simple move.", author: "Daily Motivation"),
            Quote(text: "Slow progress is still real progress.", author: "Daily Motivation")
        ]

        let source = language == .vi ? viQuotes : enQuotes
        return source[dayIndex % source.count]
    }

    private func pickStory(dayIndex: Int, language: AppLanguage) -> Story {
        let viStories: [Story] = [
            Story(
                title: "Buổi sáng thử nghiệm",
                body: "Có một người bắt đầu lại bằng việc đi bộ 15 phút mỗi sáng. Sau 2 tuần, năng lượng và tinh thần đã ổn hơn rõ rệt."
            ),
            Story(
                title: "Không đợi đến hứng",
                body: "Bạn ấy đặt giờ cố định để hành động nhỏ, dù có cảm hứng hay không. Chính sự đều đặn đã tạo ra thay đổi lớn."
            ),
            Story(
                title: "Cắt nhỏ mục tiêu",
                body: "Mục tiêu lớn được tách thành 3 bước nhỏ. Mỗi bước hoàn thành tạo động lực cho bước tiếp theo."
            ),
            Story(
                title: "Nghỉ ngơi đúng cách",
                body: "Thay vì ép bản thân liên tục, bạn ấy chèn thêm khoảng nghỉ nhẹ và đi bộ ngắn. Hiệu quả công việc tốt hơn."
            ),
            Story(
                title: "Một ghi chú mỗi ngày",
                body: "Mỗi tối, bạn ấy viết 3 dòng ghi nhận điều đã làm được. Sau một tháng, sự tự tin quay trở lại."
            )
        ]

        let enStories: [Story] = [
            Story(
                title: "A morning experiment",
                body: "One person restarted by walking for 15 minutes each morning. In two weeks, energy and mood became steadier."
            ),
            Story(
                title: "No waiting for motivation",
                body: "They set a fixed time for one tiny action, with or without motivation. Consistency created momentum."
            ),
            Story(
                title: "Shrink the goal",
                body: "A big goal was split into three tiny moves. Each completed move fueled the next one."
            ),
            Story(
                title: "Rest with intention",
                body: "Instead of forcing nonstop effort, they added short breaks and light walks. Focus improved."
            ),
            Story(
                title: "One note per day",
                body: "Every night, they wrote three lines about what went well. Confidence gradually came back."
            )
        ]

        let source = language == .vi ? viStories : enStories
        return source[dayIndex % source.count]
    }

    private func pickPrompt(dayIndex: Int, language: AppLanguage) -> String {
        let viPrompts = [
            "Hôm nay điều nhỏ nào bạn có thể hoàn thành trong 20 phút?",
            "Nếu ngày hôm nay chỉ có 1 mục tiêu, bạn sẽ chọn gì?",
            "Khoảnh khắc nào trong ngày làm bạn thấy nhẹ lòng hơn?",
            "Điều gì cần bỏ bớt để bạn dễ thở hơn hôm nay?",
            "Bạn muốn cảm ơn bản thân vì điều gì tối nay?"
        ]

        let enPrompts = [
            "What is one tiny action you can complete in 20 minutes today?",
            "If today had only one goal, what would it be?",
            "Which moment today made you feel lighter?",
            "What can you remove today to breathe easier?",
            "What would you like to thank yourself for tonight?"
        ]

        let source = language == .vi ? viPrompts : enPrompts
        return source[dayIndex % source.count]
    }

    private func pickActions(dayIndex: Int, language: AppLanguage) -> [MicroAction] {
        let viActions: [[MicroAction]] = [
            [
                MicroAction(id: "walk-2km", title: "Đi bộ 2km", detail: "Đi bộ nhẹ, giữ nhịp thở đều.", recommendedMinutes: 25),
                MicroAction(id: "water", title: "Uống nước", detail: "Uống thêm 2 ly nước vào buổi sáng.", recommendedMinutes: 5),
                MicroAction(id: "sunrise", title: "Ra ngoài 10 phút", detail: "Đứng ngoài trời và hít thở sâu.", recommendedMinutes: 10)
            ],
            [
                MicroAction(id: "stretch", title: "Giãn cơ 10 phút", detail: "Mở khớp vai, cổ, hông.", recommendedMinutes: 10),
                MicroAction(id: "focus-25", title: "Tập trung 25 phút", detail: "Làm duy nhất 1 việc quan trọng.", recommendedMinutes: 25),
                MicroAction(id: "no-phone", title: "Không cầm điện thoại", detail: "Đặt 15 phút không mạng xã hội.", recommendedMinutes: 15)
            ],
            [
                MicroAction(id: "journal-3", title: "Viết 3 dòng", detail: "Ghi lại điều đã làm được hôm nay.", recommendedMinutes: 10),
                MicroAction(id: "breathing", title: "Thở sâu", detail: "Thở 4-4-6 trong 5 vòng.", recommendedMinutes: 5),
                MicroAction(id: "clean-desk", title: "Dọn góc làm việc", detail: "Dọn dẹp 1 góc bàn nhỏ.", recommendedMinutes: 10)
            ]
        ]

        let enActions: [[MicroAction]] = [
            [
                MicroAction(id: "walk-2km", title: "Walk 2km", detail: "Keep an easy pace and steady breathing.", recommendedMinutes: 25),
                MicroAction(id: "water", title: "Hydrate", detail: "Drink two extra glasses this morning.", recommendedMinutes: 5),
                MicroAction(id: "sunrise", title: "Step outside", detail: "Spend ten calm minutes outdoors.", recommendedMinutes: 10)
            ],
            [
                MicroAction(id: "stretch", title: "Stretch for 10 minutes", detail: "Open shoulders, neck, and hips.", recommendedMinutes: 10),
                MicroAction(id: "focus-25", title: "Focus sprint", detail: "Do one important task for 25 minutes.", recommendedMinutes: 25),
                MicroAction(id: "no-phone", title: "No scrolling break", detail: "Take 15 minutes off social media.", recommendedMinutes: 15)
            ],
            [
                MicroAction(id: "journal-3", title: "Write 3 lines", detail: "Note what you completed today.", recommendedMinutes: 10),
                MicroAction(id: "breathing", title: "Deep breathing", detail: "Do 5 rounds of 4-4-6 breathing.", recommendedMinutes: 5),
                MicroAction(id: "clean-desk", title: "Reset your desk", detail: "Clean one small area around you.", recommendedMinutes: 10)
            ]
        ]

        let source = language == .vi ? viActions : enActions
        return source[dayIndex % source.count]
    }
}
