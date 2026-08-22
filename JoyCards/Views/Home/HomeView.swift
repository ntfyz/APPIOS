import SwiftUI

struct HomeView: View {
    private enum CheckState { case ready, loading, revealed }

    @State private var state: CheckState = .ready
    @State private var displayedDate = Date()
    @State private var rotation: Double = 0
    @State private var pulse = false

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            ZStack {
                background
                VStack(spacing: 28) {
                    Spacer()
                    Text("CHECK GIỜ")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .tracking(5)
                        .foregroundStyle(.white.opacity(0.7))
                    clockPanel
                    Button(action: checkTime) {
                        HStack(spacing: 10) {
                            if state == .loading { ProgressView().tint(.black) }
                            else { Image(systemName: state == .revealed ? "arrow.clockwise" : "clock.fill") }
                            Text(state == .loading ? "ĐANG CHECK..." : state == .revealed ? "CHECK LẠI" : "CHECK GIỜ")
                        }
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color(red: 0.12, green: 0.95, blue: 0.75), in: Capsule())
                        .shadow(color: Color(red: 0.12, green: 0.95, blue: 0.75).opacity(0.45), radius: 20, y: 8)
                    }
                    .buttonStyle(.plain)
                    .disabled(state == .loading)
                    Spacer()
                    Text("bấm một cái là biết")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.35))
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 44)
            }
        }
    }

    private var background: some View {
        ZStack {
            Color(red: 0.025, green: 0.035, blue: 0.08).ignoresSafeArea()
            Circle().fill(Color.cyan.opacity(0.18)).frame(width: 330).blur(radius: 80).offset(x: -120, y: -300)
            Circle().fill(Color.purple.opacity(0.16)).frame(width: 300).blur(radius: 90).offset(x: 130, y: 330)
        }
    }

    private var clockPanel: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle().stroke(Color.white.opacity(0.1), lineWidth: 10).frame(width: 86, height: 86)
                if state == .loading {
                    Circle().trim(from: 0.06, to: 0.8)
                        .stroke(Color(red: 0.12, green: 0.95, blue: 0.75), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 86, height: 86).rotationEffect(.degrees(rotation))
                } else {
                    Image(systemName: state == .revealed ? "checkmark" : "questionmark")
                        .font(.system(size: 30, weight: .black))
                        .foregroundStyle(Color(red: 0.12, green: 0.95, blue: 0.75)).scaleEffect(pulse ? 1.12 : 1)
                }
            }
            Group {
                switch state {
                case .ready: Text("-- : -- : --")
                case .loading: Text("ĐANG TÌM GIỜ...")
                case .revealed: Text(displayedDate.formatted(date: .omitted, time: .standard)).contentTransition(.numericText())
                }
            }
            .font(.system(size: state == .loading ? 22 : 44, weight: .black, design: .rounded))
            .monospacedDigit().foregroundStyle(.white)
            Text(state == .revealed ? displayedDate.formatted(.dateTime.weekday(.wide).day().month(.wide)) : "GIỜ HIỆN TẠI")
                .font(.system(size: 13, weight: .bold, design: .rounded)).foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity).padding(.vertical, 44)
        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 34, style: .continuous))
        .overlay { RoundedRectangle(cornerRadius: 34, style: .continuous).stroke(Color.white.opacity(0.13), lineWidth: 1) }
    }

    private func checkTime() {
        Haptics.medium()
        state = .loading
        rotation = 0
        withAnimation(.linear(duration: 1.25)) { rotation = 720 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
            displayedDate = Date()
            withAnimation(.spring(response: 0.38, dampingFraction: 0.62)) { state = .revealed; pulse = true }
            Haptics.success()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { withAnimation(.easeOut(duration: 0.2)) { pulse = false } }
        }
    }
}
