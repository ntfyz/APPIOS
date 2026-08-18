import SwiftUI

struct OnboardingView: View {
    var onFinish: () -> Void
    @State private var page = 0

    private let pages: [(icon: String, title: String, subtitle: String)] = [
        (
            icon: "sparkles",
            title: "Notice the little things.",
            subtitle: "Save the moments that make ordinary days special."
        ),
        (
            icon: "camera.fill",
            title: "One photo. One note.",
            subtitle: "That's all it takes."
        ),
        (
            icon: "heart.fill",
            title: "A private collection of your happiest moments.",
            subtitle: "No feeds. No likes. Just yours."
        )
    ]

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack {
                TabView(selection: $page) {
                    ForEach(pages.indices, id: \.self) { index in
                        VStack(spacing: 20) {
                            Image(systemName: pages[index].icon)
                                .font(.system(size: 64))
                                .foregroundColor(.accentColor)
                                .padding(.bottom, 8)

                            Text(pages[index].title)
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)

                            Text(pages[index].subtitle)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 32)
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: page)

                HStack(spacing: 8) {
                    ForEach(pages.indices, id: \.self) { index in
                        Capsule()
                            .fill(page == index ? Color.accentColor : Color(.systemGray4))
                            .frame(width: page == index ? 24 : 8, height: 8)
                            .animation(.easeInOut(duration: 0.25), value: page)
                    }
                }
                .padding(.top, 20)

                Button {
                    if page < pages.count - 1 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            page += 1
                        }
                    } else {
                        Haptics.success()
                        onFinish()
                    }
                } label: {
                    Text(page == pages.count - 1 ? "Start collecting" : "Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Color.accentColor.gradient,
                            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                        )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 32)
                .padding(.top, 32)

                Button("Skip") {
                    onFinish()
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 12)
            }
            .padding(.bottom, 32)
        }
    }
}

#Preview {
    OnboardingView(onFinish: {})
}