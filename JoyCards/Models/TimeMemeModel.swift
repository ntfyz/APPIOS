import Foundation
import SwiftUI

// MARK: - Khung giờ trong ngày
enum TimePeriod: String, CaseIterable, Codable, Identifiable {
    case dawn = "dawn"             // 05:00 - 07:00: Sáng sớm tinh mơ
    case morning = "morning"       // 07:00 - 11:30: Bắt đầu đi làm / đi học
    case lunch = "lunch"           // 11:30 - 13:30: Giờ ăn trưa
    case afternoon = "afternoon"   // 13:30 - 17:00: Chiều gật gù, ngóng tan ca
    case rushHour = "rushHour"     // 17:00 - 19:00: Tan tầm kẹt xe, tự do
    case evening = "evening"       // 19:00 - 22:30: Tối chill, lướt điện thoại
    case midnight = "midnight"     // 22:30 - 01:00: Nửa đêm suy nghĩ về cuộc đời
    case graveyard = "graveyard"   // 01:00 - 05:00: Giờ thiêng của các cú đêm

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dawn: return "Sáng Sớm Tinh Mơ"
        case .morning: return "Chiến Đấu Buổi Sáng"
        case .lunch: return "Hồi Máu Giờ Trưa"
        case .afternoon: return "Buồn Ngủ Đỉnh Cao"
        case .rushHour: return "Tan Tầm Bung Lụa"
        case .evening: return "Giờ Chill Lướt Phim"
        case .midnight: return "Nửa Đêm Suy Nghĩ"
        case .graveyard: return "Giờ Thiêng Cú Đêm"
        }
    }

    var badgeIcon: String {
        switch self {
        case .dawn: return "sunrise.fill"
        case .morning: return "briefcase.fill"
        case .lunch: return "fork.knife"
        case .afternoon: return "cup.and.saucer.fill"
        case .rushHour: return "figure.run"
        case .evening: return "popcorn.fill"
        case .midnight: return "moon.stars.fill"
        case .graveyard: return "ghost.fill"
        }
    }

    static func current(for date: Date = Date()) -> TimePeriod {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let totalMinutes = hour * 60 + minute

        switch totalMinutes {
        case (5 * 60)..<(7 * 60):
            return .dawn
        case (7 * 60)..<(11 * 60 + 30):
            return .morning
        case (11 * 60 + 30)..<(13 * 60 + 30):
            return .lunch
        case (13 * 60 + 30)..<(17 * 60):
            return .afternoon
        case (17 * 60)..<(19 * 60):
            return .rushHour
        case (19 * 60)..<(22 * 60 + 30):
            return .evening
        case (22 * 60 + 30)..<(24 * 60), 0..<(1 * 60):
            return .midnight
        default:
            return .graveyard
        }
    }
}

// MARK: - Meme Data Model
struct TimeMeme: Identifiable, Hashable {
    let id = UUID()
    let period: TimePeriod
    let emoji: String
    let statusText: String
    let roastText: String
    let tipText: String
    let tag: String
}

// MARK: - Theme Đồng hồ
enum ClockTheme: String, CaseIterable, Identifiable {
    case neonCyber = "Cyberpunk Neon"
    case sunsetVibe = "Sunset Chill"
    case catMeme = "Mèo Bất Lực"
    case midnightDark = "Cú Đêm OLED"
    case matchaGreen = "Trà Xanh Tỉnh Táo"

    var id: String { rawValue }

    var primaryColor: Color {
        switch self {
        case .neonCyber: return Color(red: 0.1, green: 0.95, blue: 0.8)
        case .sunsetVibe: return Color(red: 1.0, green: 0.45, blue: 0.3)
        case .catMeme: return Color(red: 1.0, green: 0.72, blue: 0.2)
        case .midnightDark: return Color(red: 0.7, green: 0.5, blue: 1.0)
        case .matchaGreen: return Color(red: 0.4, green: 0.85, blue: 0.45)
        }
    }

    var accentGradients: [Color] {
        switch self {
        case .neonCyber:
            return [Color(red: 0.05, green: 0.1, blue: 0.25), Color(red: 0.35, green: 0.05, blue: 0.45)]
        case .sunsetVibe:
            return [Color(red: 0.25, green: 0.08, blue: 0.2), Color(red: 0.85, green: 0.3, blue: 0.2)]
        case .catMeme:
            return [Color(red: 0.15, green: 0.1, blue: 0.08), Color(red: 0.5, green: 0.3, blue: 0.1)]
        case .midnightDark:
            return [Color(red: 0.06, green: 0.06, blue: 0.12), Color(red: 0.18, green: 0.12, blue: 0.3)]
        case .matchaGreen:
            return [Color(red: 0.05, green: 0.15, blue: 0.1), Color(red: 0.15, green: 0.4, blue: 0.25)]
        }
    }
}
