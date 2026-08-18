import SwiftUI

struct ProgressInfoCard: View {
    let title: String
    let value: String
    let detail: String
    let progress: Double
    var tint: Color = .accentColor

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)

                Spacer()

                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(tint)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(tint.opacity(0.15))

                    Capsule()
                        .fill(tint.gradient)
                        .frame(width: max(0, geometry.size.width * progress))
                }
            }
            .frame(height: 8)
            .animation(.easeOut(duration: 0.8), value: progress)

            Text(detail)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ProgressInfoCard(
        title: "Battery Level",
        value: "78%",
        detail: "State: Not Charging",
        progress: 0.78,
        tint: .green
    )
    .padding()
}