import SwiftUI

struct MemoryGridItem: View {
    let memory: JoyMemory

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let image = ImageStore.image(for: memory) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color(.systemGray5)
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fill)
            .clipped()

            if memory.isFavorite {
                Image(systemName: "heart.fill")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(6)
                    .background(.black.opacity(0.35), in: Circle())
                    .padding(6)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    MemoryGridItem(memory: JoyMemory.preview)
        .frame(width: 120)
        .padding()
}