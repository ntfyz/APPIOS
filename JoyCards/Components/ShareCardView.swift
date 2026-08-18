import SwiftUI

struct ShareCardView: View {
    let memory: JoyMemory

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Group {
                if let image = ImageStore.image(for: memory) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color(.systemGray5)
                }
            }
            .frame(height: 320)
            .frame(maxWidth: .infinity)
            .clipped()

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 8) {
                    Text(memory.mood.emoji)
                        .font(.system(size: 24))
                    Text(memory.note)
                        .font(.title3.weight(.semibold))
                        .lineLimit(4)
                }

                Text(memory.createdAt.formatted(.dateTime.month(.wide).day().year()))
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack(spacing: 5) {
                    Text("Joy Cards")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.accentColor)
                    Text("· a private collection of little moments")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(20)
        }
        .frame(width: 360)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 16, y: 6)
    }
}

#Preview {
    ShareCardView(memory: JoyMemory.preview)
}