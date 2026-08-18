import SwiftUI

struct CapturePreviewView: View {
    let image: UIImage
    let onRetake: () -> Void
    let onUse: () -> Void

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()

            VStack {
                Spacer()

                HStack {
                    Button("Retake", action: onRetake)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(.black.opacity(0.4), in: Capsule())

                    Spacer()

                    Button("Use Photo", action: onUse)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(Color.accentColor, in: Capsule())
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 44)
            }
        }
    }
}

#Preview {
    CapturePreviewView(
        image: UIImage(systemName: "photo")!,
        onRetake: {},
        onUse: {}
    )
}