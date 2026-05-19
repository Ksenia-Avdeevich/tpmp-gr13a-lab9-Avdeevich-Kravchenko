import XCTest
@testable import MusicShop

// MARK: - Search ViewModel Tests

final class SearchViewModelTests: XCTestCase {
    
    var sut: SearchViewModel!
    
    override func setUp() {
        super.setUp()
        DatabaseService.shared.setup()
        sut = SearchViewModel()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState_searchQueryIsEmpty() {
        XCTAssertEqual(sut.searchQuery, "")
    }
    
    func testInitialState_searchResultsAreEmpty() {
        XCTAssertTrue(sut.searchResults.isEmpty)
    }
    
    // MARK: - Recent Searches Tests
    
    func testClearRecentSearches_emptiesRecentSearches() {
        sut.clearRecentSearches()
        XCTAssertTrue(sut.recentSearches.isEmpty)
    }
    
    func testSelectRecentSearch_setsSearchQuery() {
        sut.selectRecentSearch("Pink Floyd")
        XCTAssertEqual(sut.searchQuery, "Pink Floyd")
    }
}
