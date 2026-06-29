import Foundation

struct SafetySupportNote {
    let message: String
    let isElevated: Bool

    var systemImage: String {
        isElevated ? "heart.text.square" : "info.circle"
    }
}

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
                return "Ngày mai ưu tiên phục hồi: chỉ chọn một hành động rất nhỏ, làm lúc dễ thở nhất, rồi cho bản thân nghỉ."
            }
            if completionPercent < 40 {
                if let primaryGoal {
                    return "Ngày mai chọn phiên bản nhỏ nhất của mục tiêu \(primaryGoal.title(language: language).lowercased()). Làm đủ nhỏ để bạn không cần gồng."
                }
                return "Ngày mai chỉ cần chọn một điều nhỏ nhất, đủ dễ để bắt đầu mà không cần thắng cả ngày."
            }
            if completionPercent < 80 {
                return "Ngày mai giữ lại điều đã giúp bạn dễ thở hôm nay, rồi thêm một bước nhỏ nếu cơ thể còn đồng ý."
            }
            if energyLevel == .high {
                return "Ngày mai có thể thử một bước lớn hơn một chút, nhưng đặt sẵn điểm dừng để nhịp này vẫn bền."
            }
            return "Ngày mai tiếp tục bằng một việc vừa sức. Điều quan trọng là quay lại, không phải làm thật nhiều."
        case .en:
            if energyLevel == .low || moodLevel <= 2 {
                return "Prioritize recovery tomorrow: choose one very small action, do it when breathing feels easiest, then rest."
            }
            if completionPercent < 40 {
                if let primaryGoal {
                    return "Tomorrow, choose the smallest version of your \(primaryGoal.title(language: language).lowercased()) goal. Make it small enough that you do not have to force yourself."
                }
                return "Tomorrow, choose the smallest possible thing, easy enough to begin without needing to win the whole day."
            }
            if completionPercent < 80 {
                return "Keep what helped you breathe today, then add one tiny step only if your body agrees."
            }
            if energyLevel == .high {
                return "Tomorrow can hold a slightly bigger step, as long as you set a clear stopping point."
            }
            return "Continue tomorrow with one doable action. Returning matters more than doing a lot."
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

    static func safetySupportNote(
        language: AppLanguage,
        moodLevel: Int,
        energyLevel: DailyEnergyLevel,
        weeklyRecap: WeeklyGardenRecap
    ) -> SafetySupportNote {
        let needsExtraSupport = moodLevel <= 1
            || (moodLevel <= 2 && energyLevel == .low)
            || weeklyRecap.lowMoodCount >= 3

        if needsExtraSupport {
            switch language {
            case .vi:
                return SafetySupportNote(
                    message: "Nếu hôm nay quá khó để ở một mình, hãy nhắn cho một người bạn tin cậy hoặc tìm hỗ trợ khẩn cấp tại nơi bạn sống. Nếu bạn đang ở Mỹ và có nguy cơ làm hại bản thân hoặc cần hỗ trợ khủng hoảng ngay, hãy gọi hoặc nhắn 988.",
                    isElevated: true
                )
            case .en:
                return SafetySupportNote(
                    message: "If today feels too hard to hold alone, contact someone you trust or local emergency support. If you are in the U.S. and may hurt yourself or need immediate crisis support, call or text 988.",
                    isElevated: true
                )
            }
        }

        return SafetySupportNote(
            message: safetyNote(language: language),
            isElevated: false
        )
    }
}
