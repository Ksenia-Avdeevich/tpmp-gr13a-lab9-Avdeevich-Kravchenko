import Foundation
import MapKit
import CoreLocation
import Combine

// MARK: - Map ViewModel

final class MapViewModel: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var stores: [Store] = Store.sampleStores
    @Published var selectedStore: Store?
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 53.9045, longitude: 27.5615),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @Published var locationAuthorized: Bool = false
    @Published var nearestStore: Store?
    
    // MARK: - Dependencies
    
    private let locationManager = CLLocationManager()
    
    // MARK: - Initializer
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // MARK: - Location
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func centerOnUser() {
        if let location = userLocation {
            region = MKCoordinateRegion(
                center: location,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }
    
    func centerOnStore(_ store: Store) {
        region = MKCoordinateRegion(
            center: store.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
        selectedStore = store
    }
    
    // MARK: - Nearest Store
    
    func findNearestStore() {
        guard let userLoc = userLocation else { return }
        let userCL = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
        nearestStore = stores.min {
            let loc1 = CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
            let loc2 = CLLocation(latitude: $1.coordinate.latitude, longitude: $1.coordinate.longitude)
            return loc1.distance(from: userCL) < loc2.distance(from: userCL)
        }
    }
    
    func openInMaps(store: Store) {
        let placemark = MKPlacemark(coordinate: store.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = store.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

// MARK: - CLLocationManagerDelegate

extension MapViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location.coordinate
        findNearestStore()
        locationAuthorized = true
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            locationAuthorized = true
        case .denied, .restricted:
            locationAuthorized = false
        default:
            break
        }
    }
}
