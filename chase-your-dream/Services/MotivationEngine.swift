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
                return "Hôm nay năng lượng thấp mà bạn vẫn check-in được là một tín hiệu rất đáng quý. Hãy giữ nhịp bằng một bước thật nhỏ."
            }
            if completionPercent < 40 {
                if let primaryGoal {
                    return "Bạn đã bắt đầu rồi. Chỉ cần chốt thêm 1 việc nhỏ cho mục tiêu \(primaryGoal.title(language: language).lowercased()) là hôm nay đã có điểm tựa."
                }
                return "Bạn đã bắt đầu rồi, bây giờ hãy chốt 1 việc nhỏ để đẩy tỷ lệ lên cao hơn hôm nay."
            }
            if completionPercent < 80 {
                if energyLevel == .high {
                    return "Tiến độ đang tốt và năng lượng hôm nay khá sáng. Thêm một nước rút có kiểm soát là đủ, không cần quá sức."
                }
                return "Tiến độ đang tốt. Thêm một nước rút nhỏ là bạn sẽ chạm mốc 100%."
            }
            if moodLevel <= 2 {
                return "Bạn đã làm rất tốt. Hãy thưởng cho bản thân một khoảng nghỉ nhẹ để hồi phục."
            }
            return "Tuyệt vời, bạn đang giữ được nhịp rất đẹp. Tiếp tục một hành động nhỏ vào ngày mai."
        case .en:
            if energyLevel == .low, moodLevel <= 2 {
                return "Your energy is low and you still checked in. That counts. Keep the rhythm with one very small step."
            }
            if completionPercent < 40 {
                if let primaryGoal {
                    return "You have already started. One more tiny move for \(primaryGoal.title(language: language).lowercased()) can give today a real anchor."
                }
                return "You have already started. Lock in one more tiny move today to lift the percentage."
            }
            if completionPercent < 80 {
                if energyLevel == .high {
                    return "Solid progress and bright energy today. Add one controlled sprint, without pushing past your limits."
                }
                return "Solid progress. One more focused sprint can get you much closer to 100%."
            }
            if moodLevel <= 2 {
                return "Great effort. Give yourself a gentle recovery break after this win."
            }
            return "Excellent rhythm. Keep it alive with one simple action tomorrow."
        }
    }
}
