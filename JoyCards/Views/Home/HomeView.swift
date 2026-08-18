import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \JoyMemory.createdAt, order: .reverse) private var memories: [JoyMemory]
    @State private var showCapture = false
    @State private var randomMemory: JoyMemory?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    captureButton

                    if !hasMemoryToday {
                        dailyPrompt
                    }

                    if streakCount >= 1 {
                        streakBanner
                    }

                    if !onThisDayMemories.isEmpty {
                        onThisDaySection
                    }

                    if let memory = randomMemory {
                        randomMemorySection(memory)
                    }

                    if memories.isEmpty {
                        EmptyStateView(action: { showCapture = true })
                            .padding(.top, 40)
                    } else {
                        recentJoysSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .fullScreenCover(isPresented: $showCapture) {
                CaptureFlowView()
            }
            .task {
                if randomMemory == nil {
                    randomMemory = memories.randomElement()
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(greeting)
                .font(.system(size: 34, weight: .bold, design: .rounded))
            Text("What made you smile today?")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 6)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "Good morning 👋"
        case 12..<18: return "Good afternoon 👋"
        default: return "Good evening 👋"
        }
    }

    // MARK: - Actions

    private var captureButton: some View {
        Button {
            Haptics.light()
            showCapture = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "camera.fill")
                Text("Capture a moment")
                    .fontWeight(.semibold)
            }
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
    }

    // MARK: - Daily prompt

    private var dailyPrompt: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Anything small that made you smile today?")
                .font(.headline)
            Button {
                Haptics.light()
                showCapture = true
            } label: {
                Label("Capture it", systemImage: "camera.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.accentColor, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
    }

    // MARK: - Streak

    private var streakBanner: some View {
        HStack(spacing: 10) {
            Text("🔥")
                .font(.title2)
            Text(streakText)
                .font(.subheadline.weight(.medium))
            Spacer()
        }
        .padding(16)
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }

    private var streakText: String {
        streakCount == 1
            ? "1 day of noticing good things"
            : "\(streakCount) days of noticing good things"
    }

    // MARK: - On this day

    private var onThisDaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("On this day")
                .font(.headline)
            ForEach(onThisDayMemories) { memory in
                NavigationLink {
                    MemoryDetailView(memory: memory)
                } label: {
                    JoyCardView(memory: memory)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Random memory

    private func randomMemorySection(_ memory: JoyMemory) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Remember this?")
                    .font(.headline)
                Spacer()
                Button {
                    Haptics.selection()
                    randomMemory = memories.randomElement()
                } label: {
                    Image(systemName: "dice")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            NavigationLink {
                MemoryDetailView(memory: memory)
            } label: {
                JoyCardView(memory: memory)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Recent joys

    private var recentJoysSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Joys")
                .font(.headline)
            ForEach(Array(memories.prefix(10))) { memory in
                NavigationLink {
                    MemoryDetailView(memory: memory)
                } label: {
                    JoyCardView(memory: memory)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Computed

    private var hasMemoryToday: Bool {
        memories.contains { Calendar.current.isDateInToday($0.createdAt) }
    }

    private var daysWithMemories: Set<Date> {
        Set(memories.map { Calendar.current.startOfDay(for: $0.createdAt) })
    }

    private var streakCount: Int {
        StreakCalculator.streak(daysWithMemories: daysWithMemories)
    }

    private var onThisDayMemories: [JoyMemory] {
        let calendar = Calendar.current
        let today = calendar.dateComponents([.month, .day], from: .now)
        return memories.filter { memory in
            let components = calendar.dateComponents([.month, .day], from: memory.createdAt)
            return components.month == today.month
                && components.day == today.day
                && !calendar.isDateInToday(memory.createdAt)
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: JoyMemory.self, inMemory: true)
}