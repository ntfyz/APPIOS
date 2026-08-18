import SwiftUI
import SwiftData

struct CreateJoyView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CreateJoyViewModel
    private let onSaved: (() -> Void)?
    @State private var showSaveFeedback = false

    init(image: UIImage?, existing: JoyMemory?, onSaved: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: CreateJoyViewModel(image: image, existing: existing))
        self.onSaved = onSaved
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    photoSection
                    noteSection
                    moodSection
                    tagsSection
                    locationSection
                    saveButton
                }
                .padding(20)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(viewModel.isEditing ? "Edit Joy" : "New Joy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $viewModel.showLocationSheet) {
                LocationPickerView(viewModel: viewModel)
            }
        }
    }

    // MARK: - Photo

    private var photoSection: some View {
        Group {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 260)
                    .frame(maxWidth: .infinity)
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .frame(height: 260)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                    )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    // MARK: - Note

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What happened?")
                .font(.headline)

            TextField("Write a little note...", text: $viewModel.note, axis: .vertical)
                .lineLimit(3...6)
                .padding(12)
                .background(
                    Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
                .onChange(of: viewModel.note) { _, _ in
                    viewModel.limitNote()
                }

            Text("\(viewModel.note.count)/\(CreateJoyViewModel.noteLimit)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    // MARK: - Mood

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Mood")
                .font(.headline)
            MoodPicker(selection: $viewModel.mood)
        }
    }

    // MARK: - Tags

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tags")
                .font(.headline)

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 84), spacing: 8)],
                alignment: .leading,
                spacing: 8
            ) {
                ForEach(viewModel.allTagOptions, id: \.self) { tag in
                    TagChip(
                        title: tag,
                        isSelected: viewModel.selectedTags.contains(tag)
                    ) {
                        viewModel.toggleTag(tag)
                    }
                }
            }

            HStack(spacing: 8) {
                TextField("Add custom tag", text: $viewModel.customTag)
                    .font(.subheadline)
                    .padding(12)
                    .background(
                        Color(.secondarySystemGroupedBackground),
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                    )
                    .onSubmit {
                        viewModel.addCustomTag()
                    }

                Button {
                    viewModel.addCustomTag()
                } label: {
                    Image(systemName: "plus")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(viewModel.customTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    // MARK: - Location

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Location")
                .font(.headline)

            if let location = viewModel.locationName {
                HStack {
                    Label(location, systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                    Spacer()
                    Button("Remove") {
                        viewModel.locationName = nil
                        viewModel.latitude = nil
                        viewModel.longitude = nil
                    }
                    .font(.subheadline)
                    .foregroundColor(.red)
                }
                .padding(12)
                .background(
                    Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
            } else {
                Button {
                    viewModel.showLocationSheet = true
                } label: {
                    Label("Add location", systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            Color(.secondarySystemGroupedBackground),
                            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                        )
                }
                .buttonStyle(.plain)
                .foregroundColor(.primary)
            }
        }
    }

    // MARK: - Save

    private var saveButton: some View {
        Button {
            guard viewModel.save(into: context) else { return }
            Haptics.success()
            withAnimation(.easeOut(duration: 0.25)) {
                showSaveFeedback = true
            }
            Task {
                try? await Task.sleep(nanoseconds: 600_000_000)
                if let onSaved {
                    onSaved()
                } else {
                    dismiss()
                }
            }
        } label: {
            ZStack {
                if showSaveFeedback {
                    Image(systemName: "checkmark")
                        .font(.headline)
                } else {
                    Text("Save Joy")
                        .font(.headline)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Color.accentColor.gradient,
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
        }
        .buttonStyle(.plain)
        .disabled(!viewModel.canSave || showSaveFeedback)
        .opacity(viewModel.canSave ? 1 : 0.5)
        .scaleEffect(showSaveFeedback ? 0.97 : 1)
        .animation(.easeOut(duration: 0.25), value: showSaveFeedback)
    }
}

#Preview {
    CreateJoyView(image: UIImage(systemName: "photo"), existing: nil)
        .modelContainer(for: JoyMemory.self, inMemory: true)
}