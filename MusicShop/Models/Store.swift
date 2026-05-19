import Foundation
import MapKit

// MARK: - Store Model

struct Store: Identifiable {
    let id: Int
    var name: String
    var address: String
    var phone: String
    var workingHours: String
    var coordinate: CLLocationCoordinate2D
    var imageName: String
    
    // MARK: - Initializer
    
    init(id: Int,
         name: String,
         address: String,
         phone: String,
         workingHours: String,
         latitude: Double,
         longitude: Double,
         imageName: String = "store_placeholder") {
        self.id = id
        self.name = name
        self.address = address
        self.phone = phone
        self.workingHours = workingHours
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.imageName = imageName
    }
}

// MARK: - Map Annotation

struct StoreAnnotation: Identifiable {
    let id: Int
    let coordinate: CLLocationCoordinate2D
    let title: String
    let subtitle: String
}

// MARK: - Sample Data

extension Store {
    static let sampleStores: [Store] = [
        Store(id: 1,
              name: "MusicShop Центральный",
              address: "пр. Независимости, 15, Минск",
              phone: "+375 17 123-45-67",
              workingHours: "09:00–21:00",
              latitude: 53.9045,
              longitude: 27.5615),
        Store(id: 2,
              name: "MusicShop Восток",
              address: "ул. Партизанская, 78, Минск",
              phone: "+375 17 234-56-78",
              workingHours: "10:00–20:00",
              latitude: 53.8869,
              longitude: 27.6215),
        Store(id: 3,
              name: "MusicShop Запад",
              address: "пр. Победителей, 45, Минск",
              phone: "+375 17 345-67-89",
              workingHours: "09:00–22:00",
              latitude: 53.9226,
              longitude: 27.5037),
        Store(id: 4,
              name: "MusicShop Юг",
              address: "ул. Кальварийская, 17, Минск",
              phone: "+375 17 456-78-90",
              workingHours: "10:00–21:00",
              latitude: 53.8652,
              longitude: 27.5486)
    ]
}
