import SwiftUI

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            }
        }
        .animation(.easeInOut(duration: 0.35), value: hasCompletedOnboarding)
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            MemoriesView()
                .tabItem {
                    Label("Memories", systemImage: "photo.on.rectangle.angled")
                }
            RecapView()
                .tabItem {
                    Label("Recap", systemImage: "chart.bar.fill")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}