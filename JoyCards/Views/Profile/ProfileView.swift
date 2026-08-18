import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \JoyMemory.createdAt, order: .reverse) private var memories: [JoyMemory]
    @AppStorage("remindersEnabled") private var remindersEnabled = false
    @AppStorage("reminderTime") private var reminderTime = "20:00"
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @State private var showTimePicker = false

    private var tagCounts: [(tag: String, count: Int)] {
        let counts = Dictionary(grouping: memories.flatMap(\.tags), by: { $0 })
            .mapValues { $0.count }
        return counts.sorted { $0.value > $1.value }
            .prefix(12)
            .map { ($0.key, $0.value) }
    }

    private var streakCount: Int {
        StreakCalculator.streak(
            daysWithMemories: Set(memories.map { Calendar.current.startOfDay(for: $0.createdAt) })
        )
    }

    private var favoritesCount: Int {
        memories.filter(\.isFavorite).count
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.pink)
                            .frame(width: 54, height: 54)
                            .background(Color.pink.opacity(0.12), in: Circle())
                        VStack(alignment: .leading, spacing: 3) {
                            Text("\(memories.count) \(memories.count == 1 ? "memory" : "memories")")
                                .font(.headline)
                            Text("\(streakCount) day streak")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }

                Section("Privacy") {
                    Label("Your memories stay on your device.", systemImage: "lock.shield")
                        .font(.subheadline)
                }

                Section("Notifications") {
                    Toggle("Daily reminder", isOn: $remindersEnabled)
                        .onChange(of: remindersEnabled) { _, enabled in
                            handleReminderToggle(enabled)
                        }
                    if remindersEnabled {
                        Button {
                            showTimePicker = true
                        } label: {
                            HStack {
                                Text("Time")
                                Spacer()
                                Text(reminderTime)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                Section("Tags") {
                    if tagCounts.isEmpty {
                        Text("No tags yet")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(tagCounts, id: \.tag) { item in
                            HStack {
                                Text(item.tag)
                                    .font(.subheadline)
                                Spacer()
                                Text("\(item.count)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                Section("About") {
                    Label("Joy Cards 1.0", systemImage: "sparkles")
                        .font(.subheadline)
                    Button("View onboarding again") {
                        hasCompletedOnboarding = false
                    }
                    .font(.subheadline)
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showTimePicker) {
                ReminderTimePickerView(timeString: $reminderTime) {
                    rescheduleReminder()
                }
            }
        }
    }

    // MARK: - Reminders

    private func handleReminderToggle(_ enabled: Bool) {
        if enabled {
            Task {
                let granted = await NotificationService.requestAuthorization()
                if granted {
                    rescheduleReminder()
                } else {
                    remindersEnabled = false
                }
            }
        } else {
            NotificationService.cancelDailyReminder()
        }
    }

    private func rescheduleReminder() {
        let parts = reminderTime.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return }
        NotificationService.scheduleDailyReminder(at: parts[0], minute: parts[1])
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: JoyMemory.self, inMemory: true)
}