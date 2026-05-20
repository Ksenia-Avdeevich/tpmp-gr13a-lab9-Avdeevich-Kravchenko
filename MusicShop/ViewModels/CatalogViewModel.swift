import Foundation
import Combine

// MARK: - Catalog ViewModel

final class CatalogViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var products: [Product] = []
    @Published var filteredProducts: [Product] = []
    @Published var selectedGenre: String = "All"
    @Published var isLoading: Bool = false
    @Published var currentIndex: Int = 0
    
    // MARK: - Dependencies
    
    private let dbService = DatabaseService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    
    init() {
        loadProducts()
        setupGenreFilter()
    }
    
    // MARK: - Data Loading
    
    func loadProducts() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let loaded = self.dbService.fetchAllProducts()
            DispatchQueue.main.async {
                self.products = loaded
                self.filteredProducts = loaded
                self.isLoading = false
            }
        }
    }
    
    func loadFavorites(userId: Int) {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let loaded = self.dbService.fetchFavorites(userId: userId)
            DispatchQueue.main.async {
                self.products = loaded
                self.filteredProducts = loaded
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Genre Filter
    
    private func setupGenreFilter() {
        $selectedGenre
            .sink { [weak self] genre in
                self?.applyGenreFilter(genre)
            }
            .store(in: &cancellables)
    }
    
    private func applyGenreFilter(_ genre: String) {
        if genre == "All" {
            filteredProducts = products
        } else {
            filteredProducts = products.filter { $0.genre.rawValue == genre }
        }
    }
    
    // MARK: - Favorite Toggle
    
    func toggleFavorite(product: Product, userId: Int) {
        let isFav = dbService.toggleFavorite(userId: userId, productId: product.id)
        if let idx = filteredProducts.firstIndex(where: { $0.id == product.id }) {
            filteredProducts[idx].isFavorite = isFav
        }
        if let idx = products.firstIndex(where: { $0.id == product.id }) {
            products[idx].isFavorite = isFav
        }
    }
    
    func isFavorite(product: Product, userId: Int) -> Bool {
        dbService.isFavorite(userId: userId, productId: product.id)
    }
    
    // MARK: - Swipe Navigation
    
    func swipeNext() {
        if currentIndex < filteredProducts.count - 1 {
            currentIndex += 1
        }
    }
    
    func swipePrevious() {
        if currentIndex > 0 {
            currentIndex -= 1
        }
    }
    
    // MARK: - Genre List
    
    var availableGenres: [String] {
        ["All"] + Product.Genre.allCases.map { $0.rawValue }
    }
}
