import Foundation
import SwiftData

enum Mood: String, CaseIterable, Codable, Identifiable {
    case happy
    case funny
    case loved
    case peaceful
    case excited
    case grateful
    case cool
    case proud

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .happy: "😊"
        case .funny: "😂"
        case .loved: "🥰"
        case .peaceful: "😌"
        case .excited: "🤩"
        case .grateful: "🥹"
        case .cool: "😎"
        case .proud: "🎉"
        }
    }

    var title: String {
        switch self {
        case .happy: "Happy"
        case .funny: "Funny"
        case .loved: "Loved"
        case .peaceful: "Peaceful"
        case .excited: "Excited"
        case .grateful: "Grateful"
        case .cool: "Cool"
        case .proud: "Proud"
        }
    }
}

@Model
final class JoyMemory {
    var id: UUID
    var photoPath: String
    var note: String
    var createdAt: Date
    var moodRaw: String
    var tags: [String]
    var locationName: String?
    var latitude: Double?
    var longitude: Double?
    var isFavorite: Bool
    var isTimeCapsule: Bool
    var unlockDate: Date?

    var mood: Mood {
        get { Mood(rawValue: moodRaw) ?? .happy }
        set { moodRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        photoPath: String,
        note: String,
        createdAt: Date = .now,
        mood: Mood,
        tags: [String] = [],
        locationName: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        isFavorite: Bool = false,
        isTimeCapsule: Bool = false,
        unlockDate: Date? = nil
    ) {
        self.id = id
        self.photoPath = photoPath
        self.note = note
        self.createdAt = createdAt
        self.moodRaw = mood.rawValue
        self.tags = tags
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.isFavorite = isFavorite
        self.isTimeCapsule = isTimeCapsule
        self.unlockDate = unlockDate
    }
}