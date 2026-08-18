import Foundation
import CoreLocation

@MainActor
final class LocationService: NSObject, ObservableObject {
    @Published var isLocating = false
    @Published var errorMessage: String?

    private let manager = CLLocationManager()
    private var completion: ((String?, Double?, Double?) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
    }

    func fetchCurrentLocation(completion: @escaping (String?, Double?, Double?) -> Void) {
        self.completion = completion
        isLocating = true
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            finish(nil, nil, nil)
        }
    }

    private func finish(_ name: String?, _ latitude: Double?, _ longitude: Double?) {
        isLocating = false
        completion?(name, latitude, longitude)
        completion = nil
    }
}

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            if manager.authorizationStatus == .authorizedWhenInUse
                || manager.authorizationStatus == .authorizedAlways {
                manager.requestLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        Task { @MainActor in
            let geocoder = CLGeocoder()
            let placemark = try? await geocoder.reverseGeocodeLocation(location).first
            let name = placemark?.locality ?? placemark?.name ?? "Current Location"
            self.finish(name, latitude, longitude)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.errorMessage = "Couldn't determine your location."
            self.finish(nil, nil, nil)
        }
    }
}