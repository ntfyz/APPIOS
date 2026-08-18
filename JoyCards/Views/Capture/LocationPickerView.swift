import SwiftUI

struct LocationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CreateJoyViewModel
    @StateObject private var locationService = LocationService()
    @State private var manualName = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Place name", text: $manualName)
                        .font(.subheadline)

                    Button {
                        locationService.fetchCurrentLocation { name, latitude, longitude in
                            guard let name else { return }
                            viewModel.locationName = name
                            viewModel.latitude = latitude
                            viewModel.longitude = longitude
                            dismiss()
                        }
                    } label: {
                        HStack(spacing: 10) {
                            if locationService.isLocating {
                                ProgressView()
                            } else {
                                Image(systemName: "location.fill")
                            }
                            Text(locationService.isLocating ? "Locating..." : "Use Current Location")
                        }
                    }
                    .font(.subheadline)
                    .disabled(locationService.isLocating)

                    if let message = locationService.errorMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                } footer: {
                    Text("Location is stored only on this device and shown on your cards.")
                }
            }
            .navigationTitle("Add Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        let name = manualName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !name.isEmpty else { return }
                        viewModel.locationName = name
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(manualName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    LocationPickerView(viewModel: CreateJoyViewModel(image: nil, existing: nil))
}