import SwiftUI

struct ContentView: View {
    @State private var count = 0

    private var buttonTitle: String {
        count == 0 ? "Press Me" : "Pressed!"
    }

    var body: some View {
        VStack(spacing: 16) {
            Button(action: {
                count += 1
            }) {
                Text(buttonTitle)
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }

            if count > 0 {
                Text("Pressed \(count) times")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}