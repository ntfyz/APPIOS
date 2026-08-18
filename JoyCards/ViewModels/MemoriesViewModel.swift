import Foundation

@MainActor
final class MemoriesViewModel: ObservableObject {
    func filtered(_ memories: [JoyMemory], searchText: String) -> [JoyMemory] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return memories }
        let calendar = Calendar.current
        return memories.filter { memory in
            if memory.note.lowercased().contains(query) { return true }
            if memory.tags.contains(where: { $0.lowercased().contains(query) }) { return true }
            if memory.mood.title.lowercased().contains(query) || memory.mood.emoji == query { return true }
            if let location = memory.locationName, location.lowercased().contains(query) { return true }
            if memory.createdAt.formatted(.dateTime.month(.wide)).lowercased().contains(query) { return true }
            if String(calendar.component(.year, from: memory.createdAt)).contains(query) { return true }
            return false
        }
    }
}