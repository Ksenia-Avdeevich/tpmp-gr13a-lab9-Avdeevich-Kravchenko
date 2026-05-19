import XCTest
@testable import MusicShop

// MARK: - Catalog ViewModel Tests

final class CatalogViewModelTests: XCTestCase {
    
    var sut: CatalogViewModel!
    
    override func setUp() {
        super.setUp()
        sut = CatalogViewModel()
        DatabaseService.shared.setup()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Loading Tests
    
    func testLoadProducts_populatesProductsList() {
        let expectation = expectation(description: "Products loaded")
        
        sut.loadProducts()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0) { _ in
            XCTAssertFalse(self.sut.products.isEmpty, "Products should be loaded")
        }
    }
    
    // MARK: - Genre Filter Tests
    
    func testGenreFilter_All_showsAllProducts() {
        let expectation = expectation(description: "Products loaded")
        sut.loadProducts()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { expectation.fulfill() }
        waitForExpectations(timeout: 2.0) { _ in
            self.sut.selectedGenre = "All"
            XCTAssertEqual(self.sut.filteredProducts.count, self.sut.products.count)
        }
    }
    
    func testGenreFilter_Rock_showsOnlyRockProducts() {
        let expectation = expectation(description: "Products loaded")
        sut.loadProducts()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { expectation.fulfill() }
        waitForExpectations(timeout: 2.0) { _ in
            self.sut.selectedGenre = "Rock"
            let allRock = self.sut.filteredProducts.allSatisfy { $0.genre == .rock }
            XCTAssertTrue(allRock, "Filtered products should all be Rock genre")
        }
    }
    
    // MARK: - Swipe Navigation Tests
    
    func testSwipeNext_incrementsCurrentIndex() {
        sut.products = [
            Product(id: 1, title: "A", artist: "A", genre: .rock, price: 10, quantity: 5),
            Product(id: 2, title: "B", artist: "B", genre: .pop, price: 12, quantity: 3)
        ]
        sut.filteredProducts = sut.products
        sut.currentIndex = 0
        
        sut.swipeNext()
        
        XCTAssertEqual(sut.currentIndex, 1)
    }
    
    func testSwipeNext_doesNotExceedBounds() {
        sut.products = [
            Product(id: 1, title: "A", artist: "A", genre: .rock, price: 10, quantity: 5)
        ]
        sut.filteredProducts = sut.products
        sut.currentIndex = 0
        
        sut.swipeNext() // At last item, should not go beyond
        
        XCTAssertEqual(sut.currentIndex, 0, "Should not exceed last index")
    }
    
    func testSwipePrevious_decrementsCurrentIndex() {
        sut.products = [
            Product(id: 1, title: "A", artist: "A", genre: .rock, price: 10, quantity: 5),
            Product(id: 2, title: "B", artist: "B", genre: .pop, price: 12, quantity: 3)
        ]
        sut.filteredProducts = sut.products
        sut.currentIndex = 1
        
        sut.swipePrevious()
        
        XCTAssertEqual(sut.currentIndex, 0)
    }
    
    func testSwipePrevious_doesNotGoBelowZero() {
        sut.products = [
            Product(id: 1, title: "A", artist: "A", genre: .rock, price: 10, quantity: 5)
        ]
        sut.filteredProducts = sut.products
        sut.currentIndex = 0
        
        sut.swipePrevious()
        
        XCTAssertEqual(sut.currentIndex, 0, "Should not go below 0")
    }
    
    // MARK: - Available Genres Tests
    
    func testAvailableGenres_includesAllOption() {
        XCTAssertTrue(sut.availableGenres.contains("All"))
    }
    
    func testAvailableGenres_includesAllCases() {
        let genres = sut.availableGenres
        for genre in Product.Genre.allCases {
            XCTAssertTrue(genres.contains(genre.rawValue),
                         "Should include \(genre.rawValue)")
        }
    }
}
