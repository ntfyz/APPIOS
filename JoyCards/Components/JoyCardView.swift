import SwiftUI

struct JoyCardView: View {
    let memory: JoyMemory

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            photo

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    Text(memory.mood.emoji)
                        .font(.system(size: 22))
                    Text(memory.note)
                        .font(.headline)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 0)
                }

                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text(dateText)
                        .font(.caption)
                    if let location = memory.locationName, !location.isEmpty {
                        Text("·")
                            .font(.caption)
                        Image(systemName: "mappin.and.ellipse")
                            .font(.caption2)
                        Text(location)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
                .foregroundColor(.secondary)
            }
            .padding(16)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
    }

    private var photo: some View {
        Group {
            if let image = ImageStore.image(for: memory) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color(.systemGray5)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    )
            }
        }
        .frame(height: 190)
        .frame(maxWidth: .infinity)
        .clipped()
    }

    private var dateText: String {
        memory.createdAt.formatted(.dateTime.month(.wide).day().year())
    }
}

#Preview {
    JoyCardView(memory: JoyMemory.preview)
        .padding()
}

extension JoyMemory {
    static var preview: JoyMemory {
        JoyMemory(
            photoPath: "",
            note: "Finally found this little cafe we talked about.",
            createdAt: .now,
            mood: .happy,
            tags: ["Friends"],
            locationName: "Bangkok"
        )
    }
}