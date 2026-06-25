import Foundation

struct NextStepEngine {
    static func tomorrowSuggestion(
        completionPercent: Int,
        moodLevel: Int,
        language: AppLanguage,
        energyLevel: DailyEnergyLevel = .steady,
        primaryGoal: PersonalGrowthGoal? = nil
    ) -> String {
        switch language {
        case .vi:
            if energyLevel == .low || moodLevel <= 2 {
                return "Ngày mai ưu tiên phục hồi: chọn 1 hành động rất nhỏ, làm sớm, rồi cho bản thân nghỉ nhẹ."
            }
            if completionPercent < 40 {
                if let primaryGoal {
                    return "Ngày mai chọn 1 mục tiêu \(primaryGoal.title(language: language).lowercased()) nhỏ nhất và hoàn thành trước 10h sáng."
                }
                return "Ngày mai chỉ cần chọn 1 mục tiêu nhỏ nhất và hoàn thành trước 10h sáng."
            }
            if completionPercent < 80 {
                return "Ngày mai giữ lại 2 hành động đã tốt hôm nay, thêm 1 việc nhỏ để tăng nhịp."
            }
            if energyLevel == .high {
                return "Ngày mai thử nâng mục tiêu lên 10%, nhưng đặt sẵn một điểm dừng để không bị quá đà."
            }
            return "Ngày mai thử nâng cấp mục tiêu lên 10% nhưng vẫn giữ nhịp dễ dàng duy trì."
        case .en:
            if energyLevel == .low || moodLevel <= 2 {
                return "Prioritize recovery tomorrow: choose one very small action, do it early, then give yourself a gentle break."
            }
            if completionPercent < 40 {
                if let primaryGoal {
                    return "Tomorrow, pick the smallest \(primaryGoal.title(language: language).lowercased()) goal and finish it before 10 AM."
                }
                return "Tomorrow, pick one tiny goal and finish it before 10 AM."
            }
            if completionPercent < 80 {
                return "Keep two actions from today and add one extra tiny win tomorrow."
            }
            if energyLevel == .high {
                return "Increase your target by 10% tomorrow, but set a clear stopping point so the rhythm stays sustainable."
            }
            return "Increase your target by 10% tomorrow while keeping the same sustainable pace."
        }
    }

    static func safetyNote(language: AppLanguage) -> String {
        switch language {
        case .vi:
            return "Nội dung này mang tính động viên thông thường, không thay thế tư vấn y tế hoặc tâm lý chuyên môn."
        case .en:
            return "This content is for general motivation and does not replace professional medical or mental health advice."
        }
    }
}
