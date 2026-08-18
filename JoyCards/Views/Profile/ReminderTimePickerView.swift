import SwiftUI

struct ReminderTimePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var timeString: String
    var onSave: () -> Void
    @State private var date: Date

    init(timeString: Binding<String>, onSave: @escaping () -> Void) {
        _timeString = timeString
        self.onSave = onSave
        let parts = timeString.wrappedValue.split(separator: ":").compactMap { Int($0) }
        var components = DateComponents()
        components.hour = parts.first ?? 20
        components.minute = parts.count > 1 ? parts[1] : 0
        _date = State(initialValue: Calendar.current.date(from: components) ?? .now)
    }

    var body: some View {
        NavigationStack {
            DatePicker("Reminder time", selection: $date, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding()
                .navigationTitle("Daily Reminder")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            timeString = date.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits))
                            onSave()
                            dismiss()
                        }
                        .fontWeight(.semibold)
                    }
                }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    ReminderTimePickerView(timeString: .constant("20:00"), onSave: {})
}