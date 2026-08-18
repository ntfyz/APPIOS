import SwiftUI

struct CaptureFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var stage: Stage = .camera
    @State private var capturedImage: UIImage?
    @State private var showLibrary = false
    @State private var showCreate = false

    enum Stage {
        case camera
        case preview
    }

    var body: some View {
        ZStack {
            switch stage {
            case .camera:
                CameraView(
                    onCapture: { image in
                        capturedImage = image
                        withAnimation(.easeInOut(duration: 0.25)) {
                            stage = .preview
                        }
                    },
                    onPickFromLibrary: {
                        showLibrary = true
                    },
                    onClose: {
                        dismiss()
                    }
                )
                .transition(.opacity)

            case .preview:
                if let image = capturedImage {
                    CapturePreviewView(
                        image: image,
                        onRetake: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                stage = .camera
                            }
                        },
                        onUse: {
                            showCreate = true
                        }
                    )
                    .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: stage)
        .sheet(isPresented: $showLibrary) {
            LibraryPickerView { image in
                showLibrary = false
                capturedImage = image
                withAnimation(.easeInOut(duration: 0.25)) {
                    stage = .preview
                }
            }
        }
        .fullScreenCover(isPresented: $showCreate) {
            if let image = capturedImage {
                CreateJoyView(image: image, existing: nil) {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    CaptureFlowView()
}