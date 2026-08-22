import SwiftUI

struct LiveClockView: View {
    let currentDate: Date
    let theme: ClockTheme

    private var hourString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        return formatter.string(from: currentDate)
    }

    private var minuteString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm"
        return formatter.string(from: currentDate)
    }

    private var secondString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ss"
        return formatter.string(from: currentDate)
    }

    private var dayProgress: Double {
        MemeEngine.shared.calculateDayProgress(date: currentDate)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Ngày trong tuần & ngày tháng
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .foregroundColor(theme.primaryColor)
                Text(MemeEngine.shared.formatDayOfWeek(date: currentDate))
                    .fontWeight(.bold)
                Text("•")
                    .foregroundColor(.secondary)
                Text(MemeEngine.shared.formatDate(date: currentDate))
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.08))
            )

            // Đồng hồ số siêu to
            HStack(alignment: .center, spacing: 6) {
                // Giờ
                digitBox(hourString, label: "GIỜ")

                // Dấu hai chấm nhấp nháy
                Text(":")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(theme.primaryColor)
                    .offset(y: -10)

                // Phút
                digitBox(minuteString, label: "PHÚT")

                // Dấu hai chấm
                Text(":")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(theme.primaryColor)
                    .offset(y: -10)

                // Giây
                digitBox(secondString, label: "GIÂY", isSeconds: true)
            }
            .padding(.vertical, 8)

            // Thanh tiến trình ngày
            VStack(spacing: 6) {
                HStack {
                    Text("Đã trôi qua hôm nay:")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(dayProgress * 100))% của ngày")
                        .font(.caption.weight(.bold))
                        .foregroundColor(theme.primaryColor)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.12))
                            .frame(height: 8)

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [theme.primaryColor.opacity(0.7), theme.primaryColor],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(geo.size.width * CGFloat(dayProgress), 8), height: 8)
                            .shadow(color: theme.primaryColor.opacity(0.5), radius: 4, x: 0, y: 0)
                    }
                }
                .frame(height: 8)
            }
            .padding(.horizontal, 10)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: theme.accentGradients,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(theme.primaryColor.opacity(0.3), lineWidth: 1.5)
                )
                .shadow(color: theme.primaryColor.opacity(0.15), radius: 20, x: 0, y: 8)
        )
    }

    private func digitBox(_ value: String, label: String, isSeconds: Bool = false) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: isSeconds ? 44 : 52, weight: .black, design: .rounded))
                .foregroundColor(isSeconds ? theme.primaryColor.opacity(0.85) : .white)
                .contentTransition(.numericText())
                .frame(minWidth: isSeconds ? 62 : 72)
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.black.opacity(0.35))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )

            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
                .tracking(1)
        }
    }
}
