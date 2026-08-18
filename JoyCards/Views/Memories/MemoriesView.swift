import SwiftUI
import SwiftData

struct MemoriesView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \JoyMemory.createdAt, order: .reverse) private var memories: [JoyMemory]
    @StateObject private var viewModel = MemoriesViewModel()
    @State private var searchText = ""
    @State private var mode: Mode = .timeline
    @State private var showCapture = false

    enum Mode: String, CaseIterable, Identifiable {
        case timeline
        case grid

        var id: String { rawValue }

        var title: String {
            switch self {
            case .timeline: return "Timeline"
            case .grid: return "Grid"
            }
        }
    }

    private var filteredMemories: [JoyMemory] {
        viewModel.filtered(memories, searchText: searchText)
    }

    var body: some View {
        NavigationStack {
            Group {
                if memories.isEmpty {
                    EmptyStateView(action: { showCapture = true })
                } else if filteredMemories.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    content
                }
            }
            .searchable(text: $searchText, prompt: "Search notes, tags, moods...")
            .navigationTitle("Memories")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showCapture = true
                    } label: {
                        Image(systemName: "camera")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Picker("View", selection: $mode) {
                        ForEach(Mode.allCases) { mode in
                            Label(mode.title, systemImage: mode == .timeline ? "list.bullet" : "square.grid.2x2")
                                .tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 170)
                }
            }
            .fullScreenCover(isPresented: $showCapture) {
                CaptureFlowView()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        ScrollView {
            switch mode {
            case .timeline:
                timeline
            case .grid:
                grid
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    private var timeline: some View {
        LazyVStack(alignment: .leading, spacing: 20) {
            ForEach(groupedByDay, id: \.0) { day, items in
                Text(sectionTitle(for: day))
                    .font(.caption.weight(.bold))
                    .foregroundColor(.secondary)
                    .padding(.top, 4)

                ForEach(items) { memory in
                    NavigationLink {
                        MemoryDetailView(memory: memory)
                    } label: {
                        JoyCardView(memory: memory)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
    }

    private var grid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 108), spacing: 8)], spacing: 8) {
            ForEach(filteredMemories) { memory in
                NavigationLink {
                    MemoryDetailView(memory: memory)
                } label: {
                    MemoryGridItem(memory: memory)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
    }

    private var groupedByDay: [(Date, [JoyMemory])] {
        let calendar = Calendar.current
        let groups = Dictionary(grouping: filteredMemories) { calendar.startOfDay(for: $0.createdAt) }
        return groups.keys.sorted(by: >).map { ($0, groups[$0] ?? []) }
    }

    private func sectionTitle(for day: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(day) { return "TODAY" }
        if calendar.isDateInYesterday(day) { return "YESTERDAY" }
        return day.formatted(.dateTime.month(.wide).day().year()).uppercased()
    }
}

#Preview {
    MemoriesView()
        .modelContainer(for: JoyMemory.self, inMemory: true)
}