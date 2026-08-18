import SwiftUI

struct MoodPicker: View {
    @Binding var selection: Mood

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(Mood.allCases) { mood in
                    Button {
                        selection = mood
                        Haptics.selection()
                    } label: {
                        VStack(spacing: 6) {
                            Text(mood.emoji)
                                .font(.system(size: 30))
                                .frame(width: 58, height: 58)
                                .background(
                                    selection == mood
                                        ? Color.accentColor.opacity(0.15)
                                        : Color(.secondarySystemGroupedBackground),
                                    in: Circle()
                                )
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            selection == mood ? Color.accentColor : .clear,
                                            lineWidth: 2
                                        )
                                )
                            Text(mood.title)
                                .font(.caption2.weight(selection == mood ? .semibold : .regular))
                                .foregroundColor(selection == mood ? .accentColor : .secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 2)
        }
    }
}

#Preview {
    MoodPicker(selection: .constant(.happy))
        .padding()
}