import SwiftUI

struct ContentView: View {
    @StateObject private var manager = DeviceInfoManager()
    @State private var isRefreshing = false

    var body: some View {
        ZStack {
            backgroundGradient

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    statusBanner
                    deviceSection
                    systemSection
                    storageSection
                    batterySection
                    displaySection
                    networkSection
                    footerText
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 48)
            }
            .refreshable {
                await refresh()
            }
        }
        .task {
            manager.start()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Device Check")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                Text("System & Hardware Information")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            refreshButton
        }
        .padding(.top, 6)
    }

    private var refreshButton: some View {
        Button {
            Task { await refresh() }
        } label: {
            ZStack {
                Circle()
                    .fill(Color.accentColor.gradient)
                if isRefreshing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .frame(width: 40, height: 40)
        }
        .disabled(isRefreshing)
    }

    // MARK: - Status

    private var statusBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: manager.isDataComplete ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 17))
                .foregroundColor(manager.isDataComplete ? .green : .orange)
            Text(manager.isDataComplete ? "All Systems Normal" : "Some Data Unavailable")
                .font(.subheadline.weight(.semibold))
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .animation(.easeInOut(duration: 0.4), value: manager.isDataComplete)
    }

    // MARK: - Sections

    private var deviceSection: some View {
        InfoCard(title: "Device", icon: "iphone") {
            InfoRow(icon: "iphone", title: "Device Name", value: manager.deviceName)
            rowDivider
            InfoRow(icon: "cube", title: "Model", value: manager.model)
            rowDivider
            InfoRow(icon: "number", title: "Model Identifier", value: manager.modelIdentifier)
        }
    }

    private var systemSection: some View {
        InfoCard(title: "System", icon: "gearshape") {
            InfoRow(icon: "apple.logo", title: "System Name", value: manager.systemName)
            rowDivider
            InfoRow(icon: "arrow.up.circle", title: "iOS Version", value: manager.systemVersion)
            rowDivider
            InfoRow(icon: "memorychip", title: "Memory (RAM)", value: manager.totalRAM)
            rowDivider
            InfoRow(icon: "globe", title: "Language", value: manager.language)
            rowDivider
            InfoRow(icon: "mappin.and.ellipse", title: "Region", value: manager.region)
            rowDivider
            InfoRow(icon: "clock", title: "Time Zone", value: manager.timeZone)
        }
    }

    private var storageSection: some View {
        InfoCard(title: "Storage", icon: "internaldrive", tint: .orange) {
            ProgressInfoCard(
                title: "Used Space",
                value: manager.storageUsedPercent,
                detail: "\(manager.freeStorage) free of \(manager.totalStorage)",
                progress: manager.storageProgress,
                tint: .orange
            )
            rowDivider
            InfoRow(icon: "externaldrive", title: "Total Capacity", value: manager.totalStorage, tint: .orange)
            rowDivider
            InfoRow(icon: "arrow.down.circle", title: "Free Space", value: manager.freeStorage, tint: .orange)
        }
    }

    private var batterySection: some View {
        InfoCard(title: "Battery", icon: "battery.75percent", tint: .green) {
            ProgressInfoCard(
                title: "Battery Level",
                value: manager.batteryLevel,
                detail: "State: \(manager.batteryState)",
                progress: manager.batteryProgress,
                tint: .green
            )
        }
    }

    private var displaySection: some View {
        InfoCard(title: "Display", icon: "rectangle.on.rectangle", tint: .indigo) {
            InfoRow(icon: "rectangle.inset.filled", title: "Resolution", value: manager.resolution, tint: .indigo)
            rowDivider
            InfoRow(icon: "arrow.up.left.and.arrow.down.right", title: "Screen Scale", value: manager.screenScale, tint: .indigo)
        }
    }

    private var networkSection: some View {
        InfoCard(title: "Network", icon: "wifi", tint: .teal) {
            InfoRow(icon: "network", title: "Connection", value: manager.networkStatus, tint: .teal)
            rowDivider
            InfoRow(icon: "antenna.radiowaves.left.and.right", title: "Interface", value: manager.networkInterface, tint: .teal)
            rowDivider
            InfoRow(icon: "wifi.circle", title: "Wi-Fi Name", value: manager.wifiName, tint: .teal)
        }
    }

    private var rowDivider: some View {
        Divider()
            .opacity(0.4)
    }

    private var footerText: some View {
        Text("Data is read directly from the system. Values iOS does not expose are shown as Unavailable.")
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.accentColor.opacity(0.14),
                Color.accentColor.opacity(0.05),
                Color(.systemBackground)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Actions

    private func refresh() async {
        guard !isRefreshing else { return }
        withAnimation(.easeOut(duration: 0.3)) {
            isRefreshing = true
        }
        manager.refresh()
        try? await Task.sleep(nanoseconds: 700_000_000)
        withAnimation(.easeInOut(duration: 0.3)) {
            isRefreshing = false
        }
    }
}

#Preview {
    ContentView()
}