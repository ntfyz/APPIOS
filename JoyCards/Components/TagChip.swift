import SwiftUI

struct TagChip: View {
    let title: String
    var isSelected = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .lineLimit(1)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    isSelected ? Color.accentColor : Color(.secondarySystemGroupedBackground),
                    in: Capsule()
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        TagChip(title: "Friends", isSelected: true, action: {})
        TagChip(title: "Food", action: {})
    }
    .padding()
}