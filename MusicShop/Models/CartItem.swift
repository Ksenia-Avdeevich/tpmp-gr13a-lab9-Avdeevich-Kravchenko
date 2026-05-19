import Foundation

// MARK: - CartItem Model

struct CartItem: Identifiable {
    let id: Int
    var product: Product
    var quantity: Int
    
    // MARK: - Computed Properties
    
    var totalPrice: Double {
        product.price * Double(quantity)
    }
    
    var formattedTotalPrice: String {
        String(format: "%.2f BYN", totalPrice)
    }
}
