import Foundation
import UIKit
import Darwin
import Combine
import Network
import NetworkExtension

@MainActor
final class DeviceInfoManager: ObservableObject {

    struct Snapshot {
        var deviceName = "Unavailable"
        var model = "Unavailable"
        var modelIdentifier = "Unavailable"
        var systemName = "Unavailable"
        var systemVersion = "Unavailable"
        var totalRAM = "Unavailable"
        var totalStorage = "Unavailable"
        var freeStorage = "Unavailable"
        var storageUsedPercent = "0%"
        var storageProgress: Double = 0
        var batteryLevel = "Unavailable"
        var batteryState = "Unavailable"
        var batteryProgress: Double = 0
        var language = "Unavailable"
        var region = "Unavailable"
        var timeZone = "Unavailable"
        var resolution = "Unavailable"
        var screenScale = "Unavailable"
        var isDataComplete = false
    }

    @Published private(set) var snapshot = Snapshot()
    @Published private(set) var networkStatus = "Checking..."
    @Published private(set) var networkInterface = "Unavailable"
    @Published private(set) var wifiName = "Unavailable"
    @Published private(set) var updatedAt: Date?

    private let pathMonitor = NWPathMonitor()
    private let networkQueue = DispatchQueue(label: "DeviceInfoManager.network")

    // MARK: - Convenience accessors

    var deviceName: String { snapshot.deviceName }
    var model: String { snapshot.model }
    var modelIdentifier: String { snapshot.modelIdentifier }
    var systemName: String { snapshot.systemName }
    var systemVersion: String { snapshot.systemVersion }
    var totalRAM: String { snapshot.totalRAM }
    var totalStorage: String { snapshot.totalStorage }
    var freeStorage: String { snapshot.freeStorage }
    var storageUsedPercent: String { snapshot.storageUsedPercent }
    var storageProgress: Double { snapshot.storageProgress }
    var batteryLevel: String { snapshot.batteryLevel }
    var batteryState: String { snapshot.batteryState }
    var batteryProgress: Double { snapshot.batteryProgress }
    var language: String { snapshot.language }
    var region: String { snapshot.region }
    var timeZone: String { snapshot.timeZone }
    var resolution: String { snapshot.resolution }
    var screenScale: String { snapshot.screenScale }
    var isDataComplete: Bool { snapshot.isDataComplete }

    // MARK: - Public API

    func start() {
        setupNetworkMonitor()
        fetchWifiName()
        refresh()
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            refresh()
        }
    }

    func refresh() {
        snapshot = Self.makeSnapshot()
        updatedAt = Date()
    }

    // MARK: - Snapshot

    private static func makeSnapshot() -> Snapshot {
        var info = Snapshot()
        let device = UIDevice.current

        info.deviceName = device.name.isEmpty ? "Unavailable" : device.name

        let identifier = Self.hardwareIdentifier()
        info.modelIdentifier = identifier.isEmpty ? "Unavailable" : identifier
        info.model = Self.marketingName(for: identifier)

        info.systemName = device.systemName.isEmpty ? "Unavailable" : device.systemName
        info.systemVersion = device.systemVersion.isEmpty ? "Unavailable" : device.systemVersion

        info.totalRAM = Self.formatBytes(Int64(ProcessInfo.processInfo.physicalMemory))

        if let storage = Self.storageInfo() {
            info.totalStorage = Self.formatBytes(storage.total)
            info.freeStorage = Self.formatBytes(storage.free)
            if storage.total > 0 {
                let used = max(0, storage.total - storage.free)
                let percentage = Double(used) / Double(storage.total)
                info.storageProgress = min(1, max(0, percentage))
                info.storageUsedPercent = "\(Int(info.storageProgress * 100))%"
            }
        }

        device.isBatteryMonitoringEnabled = true
        let level = device.batteryLevel
        let state = device.batteryState
        if level >= 0, state != .unknown {
            info.batteryProgress = Double(min(1, max(0, level)))
            info.batteryLevel = "\(Int(level * 100))%"
            info.batteryState = Self.batteryStateName(state)
        }

        info.language = Locale.preferredLanguages.first ?? "Unavailable"
        info.region = Locale.current.region?.identifier ?? "Unavailable"
        info.timeZone = TimeZone.current.identifier

        if let screen = Self.currentScreen() {
            let bounds = screen.nativeBounds
            info.resolution = "\(Int(bounds.width)) x \(Int(bounds.height)) px"
            info.screenScale = String(format: "%.0fx", screen.scale)
        }

        info.isDataComplete =
            info.deviceName != "Unavailable"
            && info.model != "Unavailable"
            && info.totalStorage != "Unavailable"
            && info.systemVersion != "Unavailable"

        return info
    }

    // MARK: - Network

    private func setupNetworkMonitor() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                guard let self else { return }
                switch path.status {
                case .satisfied:
                    self.networkStatus = "Connected"
                case .unsatisfied:
                    self.networkStatus = "No Connection"
                case .requiresConnection:
                    self.networkStatus = "Requires Connection"
                @unknown default:
                    self.networkStatus = "Unknown"
                }

                if path.usesInterfaceType(.wifi) {
                    self.networkInterface = "Wi-Fi"
                } else if path.usesInterfaceType(.cellular) {
                    self.networkInterface = "Cellular"
                } else if path.usesInterfaceType(.wiredEthernet) {
                    self.networkInterface = "Ethernet"
                } else if path.status == .satisfied {
                    self.networkInterface = "Other"
                } else {
                    self.networkInterface = "Unavailable"
                }
            }
        }
        pathMonitor.start(queue: networkQueue)
    }

    private func fetchWifiName() {
        NEHotspotNetwork.fetchCurrent { [weak self] network in
            let ssid = network?.ssid ?? "Unavailable"
            Task { @MainActor in
                self?.wifiName = ssid
            }
        }
    }

    // MARK: - Helpers

    private static func batteryStateName(_ state: UIDevice.BatteryState) -> String {
        switch state {
        case .charging: return "Charging"
        case .full: return "Full"
        case .unplugged: return "Not Charging"
        case .unknown: return "Unavailable"
        @unknown default: return "Unavailable"
        }
    }

    private static func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.allowedUnits = [.useGB, .useMB]
        return formatter.string(fromByteCount: bytes)
    }

    private static func hardwareIdentifier() -> String {
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        guard size > 0 else { return "" }
        var value = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &value, &size, nil, 0)
        return String(cString: value)
    }

    private static func storageInfo() -> (total: Int64, free: Int64)? {
        let home = URL(fileURLWithPath: NSHomeDirectory())
        guard let values = try? home.resourceValues(
            forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityForImportantUsageKey]
        ) else {
            return nil
        }
        guard let total = values.volumeTotalCapacity,
              let free = values.volumeAvailableCapacityForImportantUsage else {
            return nil
        }
        return (Int64(total), Int64(free))
    }

    private static func currentScreen() -> UIScreen? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.screen
    }

    private static func marketingName(for identifier: String) -> String {
        if let name = modelNames[identifier] {
            return name
        }
        if identifier.hasPrefix("iPhone") {
            return "iPhone (\(identifier))"
        }
        if identifier.hasPrefix("iPad") {
            return "iPad (\(identifier))"
        }
        if identifier == "i386" || identifier == "x86_64" || identifier == "arm64" {
            return "Simulator"
        }
        return identifier
    }

    private static let modelNames: [String: String] = [
        "iPhone1,1": "iPhone",
        "iPhone1,2": "iPhone 3G",
        "iPhone2,1": "iPhone 3GS",
        "iPhone3,1": "iPhone 4",
        "iPhone3,2": "iPhone 4",
        "iPhone3,3": "iPhone 4 (CDMA)",
        "iPhone4,1": "iPhone 4s",
        "iPhone5,1": "iPhone 5",
        "iPhone5,2": "iPhone 5",
        "iPhone5,3": "iPhone 5c",
        "iPhone5,4": "iPhone 5c",
        "iPhone6,1": "iPhone 5s",
        "iPhone6,2": "iPhone 5s",
        "iPhone7,1": "iPhone 6 Plus",
        "iPhone7,2": "iPhone 6",
        "iPhone8,1": "iPhone 6s",
        "iPhone8,2": "iPhone 6s Plus",
        "iPhone8,4": "iPhone SE (1st generation)",
        "iPhone9,1": "iPhone 7",
        "iPhone9,2": "iPhone 7 Plus",
        "iPhone9,3": "iPhone 7",
        "iPhone9,4": "iPhone 7 Plus",
        "iPhone10,1": "iPhone 8",
        "iPhone10,2": "iPhone 8 Plus",
        "iPhone10,3": "iPhone X",
        "iPhone10,4": "iPhone 8",
        "iPhone10,5": "iPhone 8 Plus",
        "iPhone10,6": "iPhone X",
        "iPhone11,2": "iPhone XS",
        "iPhone11,4": "iPhone XS Max",
        "iPhone11,6": "iPhone XS Max",
        "iPhone11,8": "iPhone XR",
        "iPhone12,1": "iPhone 11",
        "iPhone12,3": "iPhone 11 Pro",
        "iPhone12,5": "iPhone 11 Pro Max",
        "iPhone12,8": "iPhone SE (2nd generation)",
        "iPhone13,1": "iPhone 12 mini",
        "iPhone13,2": "iPhone 12",
        "iPhone13,3": "iPhone 12 Pro",
        "iPhone13,4": "iPhone 12 Pro Max",
        "iPhone14,2": "iPhone 13 Pro",
        "iPhone14,3": "iPhone 13 Pro Max",
        "iPhone14,4": "iPhone 13 mini",
        "iPhone14,5": "iPhone 13",
        "iPhone14,6": "iPhone SE (3rd generation)",
        "iPhone14,7": "iPhone 14",
        "iPhone14,8": "iPhone 14 Plus",
        "iPhone15,2": "iPhone 14 Pro",
        "iPhone15,3": "iPhone 14 Pro Max",
        "iPhone15,4": "iPhone 15",
        "iPhone15,5": "iPhone 15 Plus",
        "iPhone16,1": "iPhone 15 Pro",
        "iPhone16,2": "iPhone 15 Pro Max",
        "iPhone17,1": "iPhone 16 Pro",
        "iPhone17,2": "iPhone 16 Pro Max",
        "iPhone17,3": "iPhone 16",
        "iPhone17,4": "iPhone 16 Plus",
        "iPhone17,5": "iPhone 16e",
        "iPhone18,1": "iPhone 17",
        "iPhone18,2": "iPhone 17 Pro",
        "iPhone18,3": "iPhone 17 Pro Max",
        "iPhone18,4": "iPhone 17 Air",

        "iPad2,1": "iPad 2",
        "iPad3,1": "iPad (3rd generation)",
        "iPad3,4": "iPad (4th generation)",
        "iPad4,1": "iPad Air",
        "iPad4,4": "iPad mini 2",
        "iPad4,7": "iPad mini 3",
        "iPad5,1": "iPad mini 4",
        "iPad5,3": "iPad Air 2",
        "iPad6,3": "iPad Pro 9.7-inch",
        "iPad6,7": "iPad Pro 12.9-inch (1st generation)",
        "iPad6,11": "iPad (5th generation)",
        "iPad7,1": "iPad Pro 12.9-inch (2nd generation)",
        "iPad7,3": "iPad Pro 10.5-inch",
        "iPad7,5": "iPad (6th generation)",
        "iPad7,11": "iPad (7th generation)",
        "iPad8,1": "iPad Pro 11-inch",
        "iPad8,5": "iPad Pro 12.9-inch (3rd generation)",
        "iPad8,9": "iPad Pro 11-inch (2nd generation)",
        "iPad8,11": "iPad Pro 12.9-inch (4th generation)",
        "iPad11,1": "iPad mini (5th generation)",
        "iPad11,3": "iPad Air (3rd generation)",
        "iPad11,6": "iPad (8th generation)",
        "iPad12,1": "iPad (9th generation)",
        "iPad13,1": "iPad Air (4th generation)",
        "iPad13,4": "iPad Pro 11-inch (3rd generation)",
        "iPad13,8": "iPad Pro 12.9-inch (5th generation)",
        "iPad14,1": "iPad mini (6th generation)",
        "iPad14,3": "iPad Pro 11-inch (4th generation)",
        "iPad14,5": "iPad Pro 12.9-inch (6th generation)",
        "iPad14,8": "iPad Air (5th generation)",
        "iPad14,10": "iPad Air 11-inch (M2)",
        "iPad14,12": "iPad Air 13-inch (M2)",
        "iPad15,3": "iPad Pro 11-inch (M4)",
        "iPad15,5": "iPad Pro 13-inch (M4)",

        "iPod1,1": "iPod touch",
        "iPod2,1": "iPod touch (2nd generation)",
        "iPod3,1": "iPod touch (3rd generation)",
        "iPod4,1": "iPod touch (4th generation)",
        "iPod5,1": "iPod touch (5th generation)",
        "iPod7,1": "iPod touch (6th generation)",
        "iPod9,1": "iPod touch (7th generation)",
    ]
}