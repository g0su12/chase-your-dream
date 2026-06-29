# Chase Your Dream

Chase Your Dream là một ứng dụng iOS SwiftUI giúp người dùng quay lại với những bước tiến nhỏ mỗi ngày. Thay vì tạo áp lực bằng mục tiêu lớn, app tập trung vào check-in hằng ngày, micro action, nhật ký cảm xúc và các thông điệp động viên ngắn gọn.

Sản phẩm đang ở giai đoạn MVP, nhưng đã có hướng đi rõ: trở thành một không gian nhẹ nhàng để người dùng giữ nhịp sống, nhìn lại hành trình và tự tạo động lực bằng các hành động rất nhỏ.

## Ý Tưởng Sản Phẩm

Người dùng mục tiêu là những người đang cần một điểm tựa nhẹ để bắt đầu lại, duy trì thói quen, hoặc vượt qua cảm giác mệt mỏi/mông lung trong ngày. App không đẩy người dùng vào cảm giác phải "thay đổi cuộc đời ngay lập tức", mà dẫn dắt bằng:

- Lời chào onboarding có tính đồng cảm.
- Lựa chọn trạng thái cảm xúc ban đầu.
- Một "micro win" đầu tiên rất dễ hoàn thành.
- Gói nội dung mỗi ngày gồm trích dẫn, câu chuyện ngắn, câu hỏi tự vấn và hành động nhỏ.
- Check-in mức nở trong ngày, tâm trạng và ghi chú ngắn.
- Phản hồi động viên và gợi ý cho ngày mai dựa trên mức nở/tâm trạng.

## Tính Năng Hiện Tại

- Onboarding song ngữ Việt/Anh, có lưu trạng thái cảm xúc ban đầu bằng `AppStorage`.
- Màn hình Today theo hướng healing sanctuary với gói nội dung theo ngày, chọn ngày, pull-to-refresh và cache fallback.
- Micro actions mỗi ngày, chọn "mức nở hôm nay", mood selector animated và short journal.
- Cá nhân hóa local theo mục tiêu cá nhân và mức năng lượng hôm nay.
- Engine phản hồi động viên dựa trên `completionPercent` và `moodLevel`.
- Engine gợi ý ngày mai kèm safety note, tránh định vị app như tư vấn y tế/tâm lý.
- Lưu check-in, favorite và mood journal bằng SwiftData.
- Màn hình Vườn thay cho Progress: mỗi check-in trở thành một mầm/lá chuyển động nhẹ, có giọt sương cho low-energy wins.
- Màn hình Favorites cho quote/story, có normalized ID để tránh trùng khi đổi ngôn ngữ.
- Màn hình Journal timeline cho các ghi chú cảm xúc.
- Settings cho ngôn ngữ, giao diện system/dark/light, lịch nhắc hằng ngày và debug offline cache.
- Settings cho mục tiêu cá nhân: sức khỏe, học tập, công việc, tinh thần, kỷ luật.
- Local notification scheduler cho các khung giờ nhắc nhở mỗi ngày.
- Healing theme riêng với màu nền, card style và các minh họa nhỏ bằng SwiftUI.

## Kiến Trúc Hiện Tại

```text
chase-your-dream/
|-- Models/
|   `-- AppModels.swift
|-- Services/
|   |-- DailyContentService.swift
|   |-- MotivationEngine.swift
|   |-- NextStepEngine.swift
|   `-- NotificationScheduler.swift
|-- ViewModels/
|   `-- TodayViewModel.swift
|-- Views/
|   |-- Components/
|   |   `-- HealingIllustrations.swift
|   |-- FavoritesListView.swift
|   |-- JournalTimelineView.swift
|   |-- OnboardingView.swift
|   |-- HealingGardenView.swift
|   |-- SettingsScreenView.swift
|   `-- TodayView.swift
|-- Utilities/
|   |-- DayKeyFormatter.swift
|   |-- HealingTheme.swift
|   `-- ReminderTimeCodec.swift
|-- ContentView.swift
|-- PersistenceController.swift
`-- chase_your_dreamApp.swift
```

### Lớp Dữ Liệu

`AppModels.swift` gom các enum cấu hình app, model nội dung hằng ngày và các SwiftData model:

- `PersonalGrowthGoal`, `DailyEnergyLevel`, `DailyPersonalization`: profile local dùng để cá nhân hóa prompt/action/feedback.
- `DailyCheckinRecord`: check-in theo ngày, action đã hoàn thành, phần trăm, mood, energy, goals và note.
- `FavoriteRecord`: quote/story yêu thích.
- `MoodJournalEntry`: prompt, note và mood cho timeline nhật ký.

`PersistenceController` tạo `ModelContainer` với CloudKit automatic trước, fallback về local configuration nếu CloudKit không sẵn sàng.

### Lớp Service

- `DailyContentServicing`: protocol để tách nguồn dữ liệu hằng ngày khỏi UI.
- `MockDailyContentService`: tạo nội dung local theo ngày/ngôn ngữ, có cache UserDefaults và chế độ giả lập mất mạng.
- `MotivationEngine`: sinh thông điệp động viên sau khi save check-in, có xét mục tiêu và năng lượng.
- `NextStepEngine`: sinh gợi ý cho ngày mai và safety note, có xét mục tiêu và năng lượng.
- `NotificationScheduler`: xin quyền và lên lịch local notification.

### Lớp UI

`ContentView` điều hướng giữa onboarding và tab app chính. App chính có 5 tab: Today, Garden, Favorites, Journal và Settings.

`TodayViewModel` là nơi điều phối chính của Today: load package, hydrate check-in cũ, save check-in/journal, cập nhật feedback và summary hôm qua.

## Cách Chạy Dự Án

1. Mở `chase-your-dream.xcodeproj` bằng Xcode.
2. Chọn scheme `chase-your-dream`.
3. Chọn simulator iPhone hoặc thiết bị thật.
4. Build và run.

Lưu ý: project đang dùng SwiftUI, SwiftData và local notifications. Nếu build bằng command line, máy cần active developer directory trỏ đến Xcode đầy đủ thay vì Command Line Tools.

## Hướng Xây Dựng Tiếp Theo

### 1. Biến Mock Content Thành Content System Thật

Hiện tại daily package được sinh từ mảng local trong `MockDailyContentService`. Bước tiếp theo nên tách thành:

- `LocalDailyContentService` cho offline/default content.
- `RemoteDailyContentService` để lấy gói nội dung từ backend/CMS.
- Content schema có version, category, mood intent và difficulty.
- Cache theo ngày/ngôn ngữ/segment người dùng.

### 2. Cá Nhân Hóa Onboarding Và Gợi Ý

Mục tiêu cá nhân và năng lượng hôm nay đã ảnh hưởng tới prompt/action/feedback ở local. Nên tiếp tục:

- Dùng `onboardingEmotion` để chọn tone nội dung ban đầu.
- Lưu năng lượng theo từng ngày nếu cần phân tích lịch sử.
- Tạo micro action dựa trên mood history thay vì chỉ dựa trên lựa chọn hiện tại.
- Giảm gợi ý khi mood thấp, tăng challenge khi người dùng duy trì tốt.

### 3. Nâng Cấp Vườn Cảm Xúc

Progress dạng bảng đã được thay bằng Vườn cảm xúc. Nên bổ sung:

- Các mùa/thời tiết theo mood trend.
- Các loài cây/hoa theo mục tiêu cá nhân.
- Animation Rive/Lottie cho mood scene nếu muốn nâng cấp visual.
- Weekly garden recap thay cho bảng điểm.

### 4. Hoàn Thiện Journal

Mood journal đang lưu note ngắn theo prompt hằng ngày. Các hướng tốt:

- Tìm kiếm note.
- Tag/chủ đề cảm xúc.
- Prompt library theo mood.
- Export journal local.
- Khóa riêng tư bằng Face ID/Touch ID nếu app đi theo hướng nhật ký cá nhân.

### 5. Cải Thiện Notification

Notification đã có nhiều khung giờ, nhưng nội dung còn cố định. Nên nâng cấp:

- Thông điệp nhắc nhở theo ngôn ngữ, mood gần nhất và tiến độ gần nhất.
- Quiet hours và ngày nghỉ.
- Quick action từ notification: mark done, open today, snooze.
- Theo dõi notification permission/status để UI phản hồi rõ hơn.

### 6. Đồng Bộ Và Sao Lưu

SwiftData đang thử CloudKit automatic và fallback local. Cần xác nhận thêm:

- iCloud entitlement và container cấu hình đúng.
- Migration plan cho SwiftData model.
- Backup/restore behavior.
- Cách xử lý conflict khi người dùng có nhiều thiết bị.

### 7. Chat/AI Coach Sau MVP

Nếu thêm AI, nên bắt đầu nhỏ và an toàn:

- Sinh reflection prompt theo ngữ cảnh người dùng.
- Gợi ý micro action có giới hạn, không thay thế tư vấn y tế/tâm lý.
- Tóm tắt journal theo tuần với tone động viên.
- Bộ lọc safety cho nội dung liên quan sức khỏe tinh thần.

### 8. Test Và Chất Lượng

Cần thêm test trước khi mở rộng mạnh:

- Unit test cho `DayKeyFormatter`, `ReminderTimeCodec`, `MotivationEngine`, `NextStepEngine`.
- Test cache fallback của daily content.
- Test normalized favorite ID khi đổi ngôn ngữ.
- UI test cho onboarding và flow save check-in.
- Snapshot/preview QA cho dark/light và Việt/Anh.

## Roadmap Đề Xuất

### Milestone 1: MVP On-Device Hoàn Chỉnh

- Onboarding on-device.
- Daily package local.
- Check-in, favorites, journal, garden.
- Reminder schedule.
- Theme sáng/tối.
- README và cấu trúc code rõ ràng.

### Milestone 2: Personalization

- Dùng emotion/mood/history để cá nhân hóa gợi ý.
- Bổ sung category mục tiêu.
- Cải thiện Vườn cảm xúc và journal.

### Milestone 3: Cloud Và Content Pipeline

- Backend/CMS cho daily content.
- Đồng bộ iCloud/CloudKit được test kỹ.
- Migration/versioning cho content và SwiftData.

### Milestone 4: AI-Assisted Coach

- Prompt cá nhân hóa.
- Weekly reflection.
- Micro action recommender.
- Safety guardrails rõ ràng.

## Nguyên Tắc Sản Phẩm Nên Giữ

- Nhẹ nhàng hơn là gây áp lực.
- Nhỏ nhưng hoàn thành được.
- Động viên nhưng không hứa hẹn quá mức.
- Ưu tiên riêng tư và cảm giác an toàn.
- Đo tiến bộ bằng sự quay lại đều đặn, không chỉ bằng thành tích.
