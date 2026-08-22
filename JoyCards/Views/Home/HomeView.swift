import SwiftUI
import SwiftData

struct HomeView: View {
    @AppStorage("todayCheckCount") private var checkCount: Int = 0
    @AppStorage("selectedTheme") private var selectedThemeRaw: String = ClockTheme.neonCyber.rawValue
    @State private var currentMeme: TimeMeme?
    @State private var showThemePicker: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var showAllPeriodsSheet: Bool = false

    private var currentTheme: ClockTheme {
        ClockTheme(rawValue: selectedThemeRaw) ?? .neonCyber
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            let date = context.date
            let period = TimePeriod.current(for: date)

            NavigationStack {
                ScrollView {
                    VStack(spacing: 22) {
                        // Header bar
                        topBar

                        // Live Big Clock
                        LiveClockView(currentDate: date, theme: currentTheme)

                        // Live Meme & Roast Card
                        if let meme = currentMeme {
                            MemeCardView(
                                meme: meme,
                                theme: currentTheme,
                                checkCount: checkCount,
                                onQuickCheck: {
                                    refreshMeme(for: period)
                                    checkCount += 1
                                }
                            )
                        }

                        // Các phím chức năng phụ
                        quickActionButtons

                        // Danh sách khám phá các khung giờ khác
                        explorePeriodsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
                .background(
                    Color(red: 0.07, green: 0.07, blue: 0.09)
                        .ignoresSafeArea()
                )
                .sheet(isPresented: $showThemePicker) {
                    themePickerSheet
                }
                .sheet(isPresented: $showAllPeriodsSheet) {
                    allPeriodsExplorerSheet
                }
                .onAppear {
                    if currentMeme == nil {
                        currentMeme = MemeEngine.shared.getMeme(for: period)
                    }
                }
            }
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("MEME CHECK GIỜ ⏰")
                    .font(.caption.weight(.black))
                    .foregroundColor(currentTheme.primaryColor)
                    .tracking(1.5)
                Text("Hôm nay bạn thế nào?")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)
            }

            Spacer()

            Button {
                Haptics.selection()
                showThemePicker = true
            } label: {
                Image(systemName: "paintpalette.fill")
                    .font(.title3)
                    .foregroundColor(currentTheme.primaryColor)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.08), in: Circle())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Quick Action Buttons
    private var quickActionButtons: some View {
        HStack(spacing: 12) {
            Button {
                Haptics.light()
                showAllPeriodsSheet = true
            } label: {
                HStack {
                    Image(systemName: "clock.arrow.2.circlepath")
                    Text("Tất Cả Khung Giờ")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)

            Button {
                Haptics.light()
                shareTimeStatus()
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Chia Sẻ Meme")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Explore Periods
    private var explorePeriodsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Khám phá các khung giờ khác")
                .font(.headline)
                .foregroundColor(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TimePeriod.allCases) { period in
                        Button {
                            Haptics.selection()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                currentMeme = MemeEngine.shared.getMeme(for: period)
                            }
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: period.badgeIcon)
                                    .font(.title2)
                                    .foregroundColor(currentMeme?.period == period ? currentTheme.primaryColor : .secondary)

                                Text(period.title)
                                    .font(.caption2.weight(.medium))
                                    .foregroundColor(currentMeme?.period == period ? .white : .secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(width: 105, height: 85)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(currentMeme?.period == period ? currentTheme.primaryColor.opacity(0.18) : Color.white.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(currentMeme?.period == period ? currentTheme.primaryColor : Color.clear, lineWidth: 1.5)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Helper Methods
    private func refreshMeme(for period: TimePeriod) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            currentMeme = MemeEngine.shared.getMeme(for: period, excludingId: currentMeme?.id)
        }
    }

    private func shareTimeStatus() {
        guard let meme = currentMeme else { return }
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let timeString = timeFormatter.string(from: Date())

        let shareText = """
        ⏰ Bây giờ là \(timeString) [\(meme.period.title)]
        \(meme.emoji) \(meme.statusText)
        "\(meme.roastText)"
        👉 \(meme.tag)
        """

        let av = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(av, animated: true, completion: nil)
        }
    }

    // MARK: - Sheets
    private var themePickerSheet: some View {
        NavigationStack {
            List(ClockTheme.allCases) { theme in
                Button {
                    selectedThemeRaw = theme.rawValue
                    showThemePicker = false
                } label: {
                    HStack(spacing: 14) {
                        Circle()
                            .fill(theme.primaryColor)
                            .frame(width: 24, height: 24)

                        Text(theme.rawValue)
                            .font(.body.weight(.medium))
                            .foregroundColor(.primary)

                        Spacer()

                        if theme == currentTheme {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Chọn Theme Đồng Hồ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Đóng") {
                        showThemePicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private var allPeriodsExplorerSheet: some View {
        NavigationStack {
            List(TimePeriod.allCases) { period in
                let sampleMeme = MemeEngine.shared.getMeme(for: period)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: period.badgeIcon)
                            .foregroundColor(.orange)
                        Text(period.title)
                            .font(.headline)
                        Spacer()
                        Text(sampleMeme.emoji)
                            .font(.title2)
                    }

                    Text(sampleMeme.statusText)
                        .font(.subheadline.weight(.semibold))

                    Text("\"\(sampleMeme.roastText)\"")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
                .padding(.vertical, 6)
            }
            .navigationTitle("24H Meme Matrix")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Xong") {
                        showAllPeriodsSheet = false
                    }
                }
            }
        }
    }
}