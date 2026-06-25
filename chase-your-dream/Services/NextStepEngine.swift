import Foundation

struct NextStepEngine {
    static func tomorrowSuggestion(completionPercent: Int, moodLevel: Int, language: AppLanguage) -> String {
        switch language {
        case .vi:
            if completionPercent < 40 {
                return "Ngày mai chỉ cần chọn 1 mục tiêu nhỏ nhất và hoàn thành trước 10h sáng."
            }
            if completionPercent < 80 {
                return "Ngày mai giữ lại 2 hành động đã tốt hôm nay, thêm 1 việc nhỏ để tăng nhịp."
            }
            if moodLevel <= 2 {
                return "Ngày mai ưu tiên phục hồi: đi bộ nhẹ 15 phút và ngủ sớm hơn 30 phút."
            }
            return "Ngày mai thử nâng cấp mục tiêu lên 10% nhưng vẫn giữ nhịp dễ dàng duy trì."
        case .en:
            if completionPercent < 40 {
                return "Tomorrow, pick one tiny goal and finish it before 10 AM."
            }
            if completionPercent < 80 {
                return "Keep two actions from today and add one extra tiny win tomorrow."
            }
            if moodLevel <= 2 {
                return "Prioritize recovery tomorrow: a 15-minute walk and 30 minutes earlier sleep."
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
