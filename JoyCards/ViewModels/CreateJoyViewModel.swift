import SwiftUI
import SwiftData

@MainActor
final class CreateJoyViewModel: ObservableObject {
    static let suggestedTags = ["Friends", "Family", "Food", "Travel", "Work", "Love", "Self", "Nature"]
    static let noteLimit = 200

    @Published var note = ""
    @Published var mood: Mood = .happy
    @Published var selectedTags: Set<String> = []
    @Published var locationName: String?
    @Published var latitude: Double?
    @Published var longitude: Double?
    @Published var image: UIImage?
    @Published var customTag = ""
    @Published var showLocationSheet = false

    let existing: JoyMemory?
    let isEditing: Bool

    init(image: UIImage?, existing: JoyMemory?) {
        self.existing = existing
        self.isEditing = existing != nil
        if let existing {
            self.note = existing.note
            self.mood = existing.mood
            self.selectedTags = Set(existing.tags)
            self.locationName = existing.locationName
            self.latitude = existing.latitude
            self.longitude = existing.longitude
            self.image = image ?? ImageStore.image(for: existing)
        } else {
            self.image = image
        }
    }

    var trimmedNote: String {
        note.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canSave: Bool {
        !trimmedNote.isEmpty && image != nil
    }

    var allTagOptions: [String] {
        Self.suggestedTags + selectedTags.filter { !Self.suggestedTags.contains($0) }.sorted()
    }

    func limitNote() {
        if note.count > Self.noteLimit {
            note = String(note.prefix(Self.noteLimit))
        }
    }

    func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }

    func addCustomTag() {
        let tag = customTag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !tag.isEmpty else { return }
        selectedTags.insert(tag)
        customTag = ""
    }

    func save(into context: ModelContext) -> Bool {
        guard canSave else { return false }

        let fileName: String
        if let image {
            if let existing, !existing.photoPath.isEmpty {
                ImageStore.delete(existing.photoPath)
            }
            guard let saved = ImageStore.save(image.normalized()) else { return false }
            fileName = saved
        } else if let existing {
            fileName = existing.photoPath
        } else {
            return false
        }

        if let existing {
            existing.photoPath = fileName
            existing.note = trimmedNote
            existing.mood = mood
            existing.tags = Array(selectedTags).sorted()
            existing.locationName = locationName
            existing.latitude = latitude
            existing.longitude = longitude
        } else {
            let memory = JoyMemory(
                photoPath: fileName,
                note: trimmedNote,
                mood: mood,
                tags: Array(selectedTags).sorted(),
                locationName: locationName,
                latitude: latitude,
                longitude: longitude
            )
            context.insert(memory)
        }

        do {
            try context.save()
            return true
        } catch {
            return false
        }
    }
}