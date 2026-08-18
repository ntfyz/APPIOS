import SwiftUI

struct InfoCard<Content: View>: View {
    let title: String
    let icon: String
    var tint: Color = .accentColor
    private let content: Content

    init(
        title: String,
        icon: String,
        tint: Color = .accentColor,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.tint = tint
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 26, height: 26)
                    .background(tint.gradient, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                Text(title)
                    .font(.system(.headline, design: .rounded))
            }

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
    }
}

#Preview {
    InfoCard(title: "Device", icon: "iphone") {
        InfoRow(icon: "iphone", title: "Device Name", value: "My iPhone")
    }
    .padding()
}