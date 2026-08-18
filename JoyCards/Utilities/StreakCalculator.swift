import Foundation

enum StreakCalculator {
    static func streak(daysWithMemories: Set<Date>, calendar: Calendar = .current) -> Int {
        var count = 0
        var day = calendar.startOfDay(for: .now)
        if !daysWithMemories.contains(day) {
            day = calendar.date(byAdding: .day, value: -1, to: day) ?? day
        }
        while daysWithMemories.contains(day) {
            count += 1
            day = calendar.date(byAdding: .day, value: -1, to: day) ?? day
        }
        return count
    }
}