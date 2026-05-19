import Foundation
import Combine

// MARK: - Search ViewModel

final class SearchViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var searchQuery: String = ""
    @Published var searchResults: [Product] = []
    @Published var isSearching: Bool = false
    @Published var recentSearches: [String] = []
    
    // MARK: - Dependencies
    
    private let dbService = DatabaseService.shared
    private let udService = UserDefaultsService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    
    init() {
        setupSearchDebounce()
        loadRecentSearches()
    }
    
    // MARK: - Search Setup
    
    private func setupSearchDebounce() {
        $searchQuery
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Search
    
    private func performSearch(query: String) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        
        isSearching = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let results = self.dbService.searchProducts(query: query)
            DispatchQueue.main.async {
                self.searchResults = results
                self.isSearching = false
                self.saveRecentSearch(query: query)
            }
        }
    }
    
    // MARK: - Recent Searches
    
    private func loadRecentSearches() {
        let stored = UserDefaults.standard.stringArray(forKey: "recentSearches") ?? []
        recentSearches = stored
    }
    
    private func saveRecentSearch(query: String) {
        var searches = recentSearches
        searches.removeAll { $0 == query }
        searches.insert(query, at: 0)
        if searches.count > 10 { searches = Array(searches.prefix(10)) }
        recentSearches = searches
        UserDefaults.standard.set(searches, forKey: "recentSearches")
        udService.lastSearchQuery = query
    }
    
    func clearRecentSearches() {
        recentSearches = []
        UserDefaults.standard.removeObject(forKey: "recentSearches")
    }
    
    func selectRecentSearch(_ query: String) {
        searchQuery = query
    }
}
