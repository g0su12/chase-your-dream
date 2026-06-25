import Foundation

struct MotivationEngine {
    static func feedback(completionPercent: Int, moodLevel: Int, language: AppLanguage) -> String {
        switch language {
        case .vi:
            if completionPercent < 40 {
                return "Bạn đã bắt đầu rồi, bây giờ hãy chốt 1 việc nhỏ để đẩy tỷ lệ lên cao hơn hôm nay."
            }
            if completionPercent < 80 {
                return "Tiến độ đang tốt. Thêm một nước rút nhỏ là bạn sẽ chạm mốc 100%."
            }
            if moodLevel <= 2 {
                return "Bạn đã làm rất tốt. Hãy thưởng cho bản thân một khoảng nghỉ nhẹ để hồi phục."
            }
            return "Tuyệt vời, bạn đang giữ được nhịp rất đẹp. Tiếp tục một hành động nhỏ vào ngày mai."
        case .en:
            if completionPercent < 40 {
                return "You have already started. Lock in one more tiny move today to lift the percentage."
            }
            if completionPercent < 80 {
                return "Solid progress. One more focused sprint can get you much closer to 100%."
            }
            if moodLevel <= 2 {
                return "Great effort. Give yourself a gentle recovery break after this win."
            }
            return "Excellent rhythm. Keep it alive with one simple action tomorrow."
        }
    }
}
