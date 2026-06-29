import Foundation

struct MotivationEngine {
    static func feedback(
        completionPercent: Int,
        moodLevel: Int,
        language: AppLanguage,
        energyLevel: DailyEnergyLevel = .steady,
        primaryGoal: PersonalGrowthGoal? = nil
    ) -> String {
        switch language {
        case .vi:
            if energyLevel == .low, moodLevel <= 2 {
                return "Có vẻ hôm nay khá nặng. Việc bạn vẫn check-in đã là một cách ở lại với chính mình. Bạn có thể dừng ở một bước rất nhỏ: uống nước, thở 3 nhịp, hoặc viết một dòng."
            }
            if completionPercent < 40 {
                if let primaryGoal {
                    return "Bạn đang ở đoạn gieo hạt. Không cần làm nhiều hơn sức mình; chỉ một việc nhỏ cho \(primaryGoal.title(language: language).lowercased()) cũng đủ tạo điểm tựa."
                }
                return "Bạn đang ở đoạn gieo hạt. Hôm nay không cần rực rỡ; chỉ cần chọn một điều nhỏ có thể làm được."
            }
            if completionPercent < 80 {
                if energyLevel == .high {
                    return "Năng lượng hôm nay có vẻ sáng hơn. Bạn có thể tiến thêm một chút, nhưng vẫn giữ một điểm dừng tử tế cho mình."
                }
                return "Một nhịp nhỏ đang hình thành rồi. Nếu còn sức, hãy chăm thêm một mầm; nếu không, như vậy cũng đã đủ cho hôm nay."
            }
            if moodLevel <= 2 {
                return "Dù bên trong còn nặng, bạn vẫn đã chăm được một phần của ngày hôm nay. Hãy cho mình một khoảng nghỉ nhẹ sau điều đó."
            }
            return "Hôm nay có một mầm khá ấm. Hãy ghi nhận nó như một dấu hiệu bạn đang biết quay về, không phải một bài kiểm tra cần hoàn hảo."
        case .en:
            if energyLevel == .low, moodLevel <= 2 {
                return "Today seems heavy. The fact that you still checked in is a way of staying with yourself. You can stop at one very small step: water, three breaths, or one honest line."
            }
            if completionPercent < 40 {
                if let primaryGoal {
                    return "You are in the seed stage. No need to do more than you can hold; one tiny move for \(primaryGoal.title(language: language).lowercased()) can still become an anchor."
                }
                return "You are in the seed stage. Today does not need to be bright; choose one small thing that feels possible."
            }
            if completionPercent < 80 {
                if energyLevel == .high {
                    return "Your energy seems a little brighter today. You can move a bit further while keeping a kind stopping point."
                }
                return "A small rhythm is forming. If you still have energy, tend one more seed; if not, this is enough for today."
            }
            if moodLevel <= 2 {
                return "Even with heaviness inside, you tended part of today. Let yourself take a gentle recovery pause after that."
            }
            return "There is a warm little bloom in today. Let it be a sign that you can return to yourself, not a test you have to perfect."
        }
    }
}
