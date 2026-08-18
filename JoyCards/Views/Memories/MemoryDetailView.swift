import SwiftUI
import SwiftData

struct MemoryDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    let memory: JoyMemory
    @State private var showEdit = false
    @State private var showDeleteConfirm = false
    @State private var showShare = false
    @State private var shareImage: UIImage?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                photo
                moodRow
                note
                metadata
                tags
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Memory")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        toggleFavorite()
                    } label: {
                        Label(
                            memory.isFavorite ? "Unfavorite" : "Favorite",
                            systemImage: memory.isFavorite ? "heart.slash" : "heart"
                        )
                    }
                    Button {
                        shareImage = renderShareImage()
                        showShare = true
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    Button {
                        showEdit = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showEdit) {
            CreateJoyView(image: nil, existing: memory)
        }
        .sheet(isPresented: $showShare) {
            if let image = shareImage {
                ShareSheet(items: [image])
            }
        }
        .confirmationDialog(
            "Delete this memory?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                deleteMemory()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Sections

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
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                    )
            }
        }
        .frame(height: 380)
        .frame(maxWidth: .infinity)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var moodRow: some View {
        HStack(spacing: 10) {
            Text(memory.mood.emoji)
                .font(.system(size: 26))
            Text(memory.mood.title)
                .font(.headline)
            Spacer()
            Button {
                toggleFavorite()
            } label: {
                Image(systemName: memory.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 20))
                    .foregroundColor(memory.isFavorite ? .pink : .secondary)
            }
            .buttonStyle(.plain)
        }
    }

    private var note: some View {
        Text(memory.note)
            .font(.title3)
            .padding(.vertical, 4)
    }

    private var metadata: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(
                memory.createdAt.formatted(.dateTime.month(.wide).day().year()),
                systemImage: "calendar"
            )
            if let location = memory.locationName, !location.isEmpty {
                Label(location, systemImage: "mappin.and.ellipse")
            }
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
    }

    @ViewBuilder
    private var tags: some View {
        if !memory.tags.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Tags")
                    .font(.headline)
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 84), spacing: 8)],
                    alignment: .leading,
                    spacing: 8
                ) {
                    ForEach(memory.tags, id: \.self) { tag in
                        TagChip(title: tag, action: {})
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func toggleFavorite() {
        memory.isFavorite.toggle()
        try? context.save()
        Haptics.light()
    }

    private func deleteMemory() {
        ImageStore.delete(memory.photoPath)
        context.delete(memory)
        try? context.save()
        dismiss()
    }

    private func renderShareImage() -> UIImage? {
        let renderer = ImageRenderer(content: ShareCardView(memory: memory))
        renderer.scale = 3
        return renderer.uiImage
    }
}

#Preview {
    NavigationStack {
        MemoryDetailView(memory: JoyMemory.preview)
    }
    .modelContainer(for: JoyMemory.self, inMemory: true)
}