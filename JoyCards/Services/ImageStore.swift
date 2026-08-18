import UIKit
import SwiftData

enum ImageStore {
    static let directory: URL = {
        let url = URL.documentsDirectory.appending(path: "Photos", directoryHint: .isDirectory)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }()

    static func save(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return nil }
        let filename = UUID().uuidString + ".jpg"
        let url = directory.appending(path: filename)
        do {
            try data.write(to: url, options: .atomic)
            return filename
        } catch {
            return nil
        }
    }

    static func load(_ filename: String) -> UIImage? {
        let url = directory.appending(path: filename)
        return UIImage(contentsOfFile: url.path)
    }

    static func delete(_ filename: String) {
        let url = directory.appending(path: filename)
        try? FileManager.default.removeItem(at: url)
    }

    static func image(for memory: JoyMemory) -> UIImage? {
        load(memory.photoPath)
    }
}