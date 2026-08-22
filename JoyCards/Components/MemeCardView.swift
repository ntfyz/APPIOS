import SwiftUI

struct MemeCardView: View {
    let meme: TimeMeme
    let theme: ClockTheme
    let checkCount: Int
    let onQuickCheck: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Header: Khung giờ & Tag
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: meme.period.badgeIcon)
                        .foregroundColor(theme.primaryColor)
                    Text(meme.period.title)
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(theme.primaryColor.opacity(0.2))
                )

                Spacer()

                Text(meme.tag)
                    .font(.caption2.weight(.medium))
                    .foregroundColor(theme.primaryColor.opacity(0.9))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.06), in: Capsule())
            }

            // Trung tâm: Emoji Meme siêu to & Status châm biếm
            HStack(spacing: 16) {
                Text(meme.emoji)
                    .font(.system(size: 64))
                    .scaleEffect(1.05)
                    .shadow(radius: 8)

                VStack(alignment: .leading, spacing: 4) {
                    Text("TRẠNG THÁI HIỆN TẠI")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                        .tracking(1.2)

                    Text(meme.statusText)
                        .font(.title3.weight(.bold))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.vertical, 4)

            // Câu roast chi tiết
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text("CÀ KHỊA THEO GIỜ:")
                        .font(.caption2.weight(.heavy))
                        .foregroundColor(.orange)
                }

                Text("\"\(meme.roastText)\"")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.92))
                    .italic()
                    .lineSpacing(4)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.black.opacity(0.3))
            )

            // Lời khuyên
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.subheadline)
                    .foregroundColor(.yellow)
                Text(meme.tipText)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
            }
            .padding(.horizontal, 4)

            // Nút "Check Giờ Nhanh / Cà Khịa Tiếp"
            Button {
                Haptics.heavy()
                onQuickCheck()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "dice.fill")
                        .font(.headline)
                    Text("Check Giờ Nhanh (Đổi Meme)")
                        .font(.headline.weight(.bold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    theme.primaryColor.gradient,
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                )
                .shadow(color: theme.primaryColor.opacity(0.4), radius: 10, x: 0, y: 4)
            }
            .buttonStyle(.plain)

            // Bộ đếm số lần check giờ hôm nay
            if checkCount > 0 {
                HStack {
                    Spacer()
                    Image(systemName: "eyes")
                        .foregroundColor(.secondary)
                    Text("Bạn đã bấm check giờ \(checkCount) lần hôm nay")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.top, -6)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(red: 0.12, green: 0.12, blue: 0.16))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}
