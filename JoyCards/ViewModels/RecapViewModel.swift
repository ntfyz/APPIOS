import Foundation

enum RecapPeriod: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"

    var id: String { rawValue }
}

@MainActor
final class RecapViewModel: ObservableObject {
    struct Recap {
        let title: String
        let subtitle: String
        let count: Int
        let daysWithMemories: Int
        let topMood: Mood?
        let topTag: String?
        let topLocation: String?
    }

    func memories(in period: RecapPeriod, from all: [JoyMemory]) -> [JoyMemory] {
        let calendar = Calendar.current
        switch period {
        case .week:
            guard let start = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: .now)) else {
                return []
            }
            return all.filter { $0.createdAt >= start }
        case .month:
            guard let start = calendar.date(from: calendar.dateComponents([.year, .month], from: .now)),
                  let range = calendar.range(of: .day, in: .month, for: .now),
                  let end = calendar.date(byAdding: .day, value: range.count - 1, to: start) else {
                return []
            }
            let endOfMonth = calendar.date(byAdding: .day, value: 1, to: end) ?? end
            return all.filter { $0.createdAt >= start && $0.createdAt < endOfMonth }
        }
    }

    func recap(for period: RecapPeriod, memories: [JoyMemory]) -> Recap {
        let calendar = Calendar.current
        let title: String
        let subtitle: String
        switch period {
        case .week:
            title = "Your Week"
            subtitle = memories.count == 1
                ? "1 little moment worth remembering."
                : "\(memories.count) little moments worth remembering."
        case .month:
            title = Date.now.formatted(.dateTime.month(.wide))
            subtitle = "Your month in little moments."
        }
        let days = Set(memories.map { calendar.startOfDay(for: $0.createdAt) }).count
        return Recap(
            title: title,
            subtitle: subtitle,
            count: memories.count,
            daysWithMemories: days,
            topMood: mostFrequent(memories.map(\.mood)),
            topTag: mostFrequent(memories.flatMap(\.tags)),
            topLocation: mostFrequent(memories.compactMap(\.locationName))
        )
    }

    private func mostFrequent<T: Hashable>(_ values: [T]) -> T? {
        var counts: [T: Int] = [:]
        for value in values {
            counts[value, default: 0] += 1
        }
        return counts.max(by: { $0.value < $1.value })?.key
    }
}