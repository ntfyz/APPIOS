import SwiftUI
import SwiftData

struct RecapView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \JoyMemory.createdAt, order: .reverse) private var memories: [JoyMemory]
    @StateObject private var viewModel = RecapViewModel()
    @State private var period: RecapPeriod = .week
    @State private var showCapture = false

    private var recapMemories: [JoyMemory] {
        viewModel.memories(in: period, from: memories)
    }

    private var recap: RecapViewModel.Recap {
        viewModel.recap(for: period, memories: recapMemories)
    }

    var body: some View {
        NavigationStack {
            Group {
                if recapMemories.isEmpty {
                    EmptyStateView(
                        title: "No memories yet",
                        subtitle: "Capture a few moments and your recap will appear here.",
                        actionTitle: "Capture a moment",
                        action: { showCapture = true }
                    )
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            header
                            collage
                            statsGrid
                            insights
                            momentsList
                        }
                        .padding(20)
                    }
                    .background(Color(.systemGroupedBackground).ignoresSafeArea())
                }
            }
            .navigationTitle("Recap")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Picker("Period", selection: $period) {
                        ForEach(RecapPeriod.allCases) { period in
                            Text(period.rawValue)
                                .tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 160)
                }
            }
            .fullScreenCover(isPresented: $showCapture) {
                CaptureFlowView()
            }
        }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(recap.title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
            Text(recap.subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var collage: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3),
            spacing: 4
        ) {
            ForEach(Array(recapMemories.prefix(9))) { memory in
                Group {
                    if let image = ImageStore.image(for: memory) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Color(.systemGray5)
                    }
                }
                .frame(height: 100)
                .frame(maxWidth: .infinity)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
    }

    private var statsGrid: some View {
        HStack(spacing: 12) {
            statCard(value: "\(recap.count)", label: recap.count == 1 ? "memory" : "memories")
            statCard(value: "\(recap.daysWithMemories)", label: recap.daysWithMemories == 1 ? "day" : "days")
            statCard(value: recap.topMood?.emoji ?? "—", label: recap.topMood?.title ?? "top mood")
        }
    }

    private func statCard(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.weight(.bold))
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
    }

    private var insights: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let tag = recap.topTag {
                Label("Most used tag: \(tag)", systemImage: "tag")
            }
            if let location = recap.topLocation {
                Label("Most frequent place: \(location)", systemImage: "mappin.and.ellipse")
            }
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
    }

    private var momentsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Moments")
                .font(.headline)
            ForEach(recapMemories) { memory in
                NavigationLink {
                    MemoryDetailView(memory: memory)
                } label: {
                    JoyCardView(memory: memory)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    RecapView()
        .modelContainer(for: JoyMemory.self, inMemory: true)
}