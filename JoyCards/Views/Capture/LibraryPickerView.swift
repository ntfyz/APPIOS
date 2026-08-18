import SwiftUI
import PhotosUI

struct LibraryPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let onPick: (UIImage) -> Void
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                ContentUnavailableView(
                    "Choose a Photo",
                    systemImage: "photo.on.rectangle.angled",
                    description: Text("Pick a moment from your library.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Photo Library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .onChange(of: selectedItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    onPick(image)
                }
            }
        }
    }
}

#Preview {
    LibraryPickerView(onPick: { _ in })
}