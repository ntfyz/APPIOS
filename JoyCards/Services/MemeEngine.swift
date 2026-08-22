import Foundation
import SwiftUI

class MemeEngine {
    static let shared = MemeEngine()

    private let memes: [TimeMeme] = [
        // DAWN: 05:00 - 07:00
        TimeMeme(
            period: .dawn,
            emoji: "🥱🐔",
            statusText: "Ai ép bạn dậy giờ này vậy?",
            roastText: "Mặt trời còn chưa kịp thức giấc mà bạn đã mở mắt xem điện thoại rồi. Có chuyện gì bất an à?",
            tipText: "Làm một ngụm nước ấm rồi hẵng tiếp tục làm người.",
            tag: "#DaySomDeThanhCongNhungMetQua"
        ),
        TimeMeme(
            period: .dawn,
            emoji: "🧟‍♂️☕",
            statusText: "Chế độ Zombie kích hoạt",
            roastText: "Mắt mở nhưng não vẫn đang chạy bản cập nhật chưa xong.",
            tipText: "Cần nạp 1 ly cafe sữa đá đậm đặc gấp!",
            tag: "#ZombieBuoiSang"
        ),

        // MORNING: 07:00 - 11:30
        TimeMeme(
            period: .morning,
            emoji: "💼💻",
            statusText: "Giả vờ đang bận rộn",
            roastText: "Mở 20 tab trình duyệt, gõ phím cành cạch nhưng thật ra đang canh đồng hồ trưa.",
            tipText: "Đừng để sếp thấy bạn đang check meme giờ nhé!",
            tag: "#DuaNhauVoiDeadline"
        ),
        TimeMeme(
            period: .morning,
            emoji: "📈🙃",
            statusText: "Tinh thần cống hiến: 1%",
            roastText: "Cơ thể ở công ty/trường học nhưng tâm hồn đã bay về chiếc giường ấm áp.",
            tipText: "Uống thêm nước đi, đỡ ngáp.",
            tag: "#NhanVienGuongMau"
        ),

        // LUNCH: 11:30 - 13:30
        TimeMeme(
            period: .lunch,
            emoji: "🍱🤤",
            statusText: "Ăn gì bây giờ? Câu hỏi thế kỷ!",
            roastText: "Dành 45 phút lướt menu chỉ để cuối cùng gọi lại quán cơm tấm quen thuộc.",
            tipText: "Ăn nhanh còn kịp chợp mắt 15 phút.",
            tag: "#AnTruaChuaNguoiOi"
        ),
        TimeMeme(
            period: .lunch,
            emoji: "🧋💤",
            statusText: "Căng da bụng - Trùng da mắt",
            roastText: "Vừa húp xong ly trà sữa, mi mắt nặng như gắn tạ 10kg.",
            tipText: "Tìm chỗ êm ái mà ngả lưng ngay đi.",
            tag: "#NoBungBuonNgu"
        ),

        // AFTERNOON: 13:30 - 17:00
        TimeMeme(
            period: .afternoon,
            emoji: "😴⏰",
            statusText: "1 phút dài bằng 1 năm",
            roastText: "Cứ 3 phút bạn lại liếc đồng hồ 1 lần đúng không? Kim đồng hồ như bị ai bôi keo dính vậy!",
            tipText: "Rửa mặt nước lạnh hoặc làm thêm 1 ly trà đào.",
            tag: "#DiemDanhBuonNgu"
        ),
        TimeMeme(
            period: .afternoon,
            emoji: "🔋⚡",
            statusText: "Pin sinh học còn 2%",
            roastText: "Đang duy trì sự sống bằng niềm tin và hi vọng tới 5 giờ chiều.",
            tipText: "Cố lên, sắp được giải thoát rồi!",
            tag: "#NgongTanCa"
        ),

        // RUSH HOUR: 17:00 - 19:00
        TimeMeme(
            period: .rushHour,
            emoji: "🛵💨",
            statusText: "Bấm chuông là phóng!",
            roastText: "Kỹ năng tắt máy tính trong 0.5s và lao ra khỏi cửa đạt cấp độ Thần Thoại.",
            tipText: "Đi đường cẩn thận, nhớ bật xi-nhan nha quý zị!",
            tag: "#TanLamLaChien"
        ),
        TimeMeme(
            period: .rushHour,
            emoji: "🚦🔥",
            statusText: "Hòa mình vào biển xe",
            roastText: "Đứng giữa ngã tư hít khói xe và nhận ra: Trưởng thành thật là thú vị...",
            tipText: "Bật một bài nhạc hay nghe cho bớt quạu.",
            tag: "#KetXeKhongLoiThoat"
        ),

        // EVENING: 19:00 - 22:30
        TimeMeme(
            period: .evening,
            emoji: "🛋️📱",
            statusText: "Thời gian vàng cho bản thân",
            roastText: "Nằm lăn lộn trên giường, bấm lướt TikTok bảo xem 'nốt 5 phút' nhưng trôi qua 2 tiếng rồi.",
            tipText: "Nhớ sạc pin điện thoại đi nha.",
            tag: "#LuotMangXuyenLucDia"
        ),
        TimeMeme(
            period: .evening,
            emoji: "🍿✨",
            statusText: "Chill hết nấc",
            roastText: "Tối nay không deadline, không áp lực, chỉ có bạn và sự lười biếng đáng yêu.",
            tipText: "Xem phim gì đó hài hước đi!",
            tag: "#TamGacAuLo"
        ),

        // MIDNIGHT: 22:30 - 01:00
        TimeMeme(
            period: .midnight,
            emoji: "🌌💭",
            statusText: "Hội nghị bàn tròn trong não",
            roastText: "Bắt đầu nhớ lại câu nói quê độ từ 5 năm trước và hối hận sao lúc đó không cãi lại ngầu hơn.",
            tipText: "Cất điện thoại xuống và nhắm mắt lại đi nào!",
            tag: "#SuyNghiLucNuaDem"
        ),
        TimeMeme(
            period: .midnight,
            emoji: "🛏️👀",
            statusText: "Tự hứa: '11h ngủ'",
            roastText: "Và hiện tại đã qua nửa đêm, chiếc mắt vẫn sáng rực như đèn pha ô tô.",
            tipText: "Hít thở sâu 4-7-8 để dễ vào giấc ngủ nhé.",
            tag: "#CuDemChuaNgu"
        ),

        // GRAVEYARD: 01:00 - 05:00
        TimeMeme(
            period: .graveyard,
            emoji: "🐼👻",
            statusText: "Cảnh báo: Giờ của Cú Đêm & Linh Hồn!",
            roastText: "Giờ này mà bạn còn thức để check app thì ngày mai xác định làm gấu trúc cosplay nha!",
            tipText: "NGỦ NGAY LẬP TỨC! Đừng để cơ thể biểu tình!",
            tag: "#GioThieng1Toi5Am"
        ),
        TimeMeme(
            period: .graveyard,
            emoji: "💀⚡",
            statusText: "Sắp gặp tổ tiên?",
            roastText: "Nếu bây giờ ngủ thì sẽ ngủ được chính xác... 3 tiếng 15 phút. Tuyệt vời!",
            tipText: "Tắt màn hình ngay, sức khỏe là vàng!",
            tag: "#ThucKhuyaHaiSucKhoe"
        )
    ]

    func getMeme(for period: TimePeriod, excludingId: UUID? = nil) -> TimeMeme {
        let matching = memes.filter { $0.period == period }
        if let excludingId = excludingId, matching.count > 1 {
            let filtered = matching.filter { $0.id != excludingId }
            return filtered.randomElement() ?? matching[0]
        }
        return matching.randomElement() ?? memes[0]
    }

    func getRandomRoast(for period: TimePeriod) -> TimeMeme {
        let matching = memes.filter { $0.period == period }
        return matching.randomElement() ?? memes.randomElement()!
    }

    func calculateDayProgress(date: Date = Date()) -> Double {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)

        let totalSecondsPassed = Double(hour * 3600 + minute * 60 + second)
        let totalSecondsInDay = 86400.0
        return min(max(totalSecondsPassed / totalSecondsInDay, 0.0), 1.0)
    }

    func formatDayOfWeek(date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date).capitalized
    }

    func formatDate(date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "dd 'tháng' MM, yyyy"
        return formatter.string(from: date)
    }
}
