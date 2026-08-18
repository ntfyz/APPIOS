import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var viewModel = CameraViewModel()
    let onCapture: (UIImage) -> Void
    let onPickFromLibrary: () -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            if viewModel.isAuthorized {
                CameraPreviewContainer(viewModel: viewModel)
                    .ignoresSafeArea()
                controls
            } else {
                unauthorizedView
            }
        }
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
    }

    private var controls: some View {
        VStack {
            HStack {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(.black.opacity(0.4), in: Circle())
                }

                Spacer()

                Button(action: onPickFromLibrary) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(.black.opacity(0.4), in: Circle())
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)

            Spacer()

            HStack {
                Button(action: viewModel.toggleFlash) {
                    Image(systemName: viewModel.isFlashOn ? "bolt.fill" : "bolt.slash")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(viewModel.isFlashOn ? .yellow : .white)
                        .frame(width: 44, height: 44)
                        .background(.black.opacity(0.4), in: Circle())
                }

                Spacer()

                Button {
                    viewModel.capturePhoto { image in
                        if let image {
                            Haptics.light()
                            onCapture(image)
                        }
                    }
                } label: {
                    Circle()
                        .strokeBorder(.white, lineWidth: 4)
                        .frame(width: 72, height: 72)
                        .overlay(
                            Circle()
                                .fill(.white)
                                .frame(width: 58, height: 58)
                        )
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: viewModel.switchCamera) {
                    Image(systemName: "arrow.triangle.2.circlepath.camera")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(.black.opacity(0.4), in: Circle())
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 44)
        }
    }

    private var unauthorizedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera")
                .font(.system(size: 44))
                .foregroundColor(.white.opacity(0.7))

            Text("Camera access is needed to capture your moments.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)

            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(32)
    }
}

struct CameraPreviewContainer: UIViewRepresentable {
    let viewModel: CameraViewModel

    func makeUIView(context: Context) -> PreviewContainerView {
        PreviewContainerView(previewLayer: viewModel.previewLayer)
    }

    func updateUIView(_ uiView: PreviewContainerView, context: Context) {}
}

final class PreviewContainerView: UIView {
    let previewLayer: AVCaptureVideoPreviewLayer

    init(previewLayer: AVCaptureVideoPreviewLayer) {
        self.previewLayer = previewLayer
        super.init(frame: .zero)
        layer.addSublayer(previewLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
    }
}