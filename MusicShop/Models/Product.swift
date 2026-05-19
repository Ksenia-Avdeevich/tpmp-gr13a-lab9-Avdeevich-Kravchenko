import Foundation

// MARK: - Product Model

struct Product: Identifiable, Codable {
    let id: Int
    var title: String
    var artist: String
    var genre: Genre
    var price: Double
    var quantity: Int
    var imageName: String
    var description: String
    var releaseYear: Int
    var isFavorite: Bool
    
    // MARK: - Nested Types
    
    enum Genre: String, Codable, CaseIterable {
        case rock = "Rock"
        case pop = "Pop"
        case jazz = "Jazz"
        case classical = "Classical"
        case electronic = "Electronic"
        case hiphop = "Hip-Hop"
        case country = "Country"
        case blues = "Blues"
        
        var localizedName: String {
            switch self {
            case .rock: return NSLocalizedString("genre_rock", comment: "")
            case .pop: return NSLocalizedString("genre_pop", comment: "")
            case .jazz: return NSLocalizedString("genre_jazz", comment: "")
            case .classical: return NSLocalizedString("genre_classical", comment: "")
            case .electronic: return NSLocalizedString("genre_electronic", comment: "")
            case .hiphop: return NSLocalizedString("genre_hiphop", comment: "")
            case .country: return NSLocalizedString("genre_country", comment: "")
            case .blues: return NSLocalizedString("genre_blues", comment: "")
            }
        }
    }
    
    // MARK: - Initializer
    
    init(id: Int = 0,
         title: String,
         artist: String,
         genre: Genre,
         price: Double,
         quantity: Int,
         imageName: String = "music_placeholder",
         description: String = "",
         releaseYear: Int = 2024,
         isFavorite: Bool = false) {
        self.id = id
        self.title = title
        self.artist = artist
        self.genre = genre
        self.price = price
        self.quantity = quantity
        self.imageName = imageName
        self.description = description
        self.releaseYear = releaseYear
        self.isFavorite = isFavorite
    }
    
    // MARK: - Computed Properties
    
    var formattedPrice: String {
        String(format: "%.2f BYN", price)
    }
    
    var isInStock: Bool {
        quantity > 0
    }
}
