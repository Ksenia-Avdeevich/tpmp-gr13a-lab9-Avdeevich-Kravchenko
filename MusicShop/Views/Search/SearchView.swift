import SwiftUI

// MARK: - Search View

struct SearchView: View {
    
    // MARK: - Environment & State
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var searchViewModel: SearchViewModel
    @State private var selectedProduct: Product?
    @FocusState private var isSearchFocused: Bool
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                searchBar
                
                // Content
                if searchViewModel.searchQuery.isEmpty {
                    recentSearchesView
                } else if searchViewModel.isSearching {
                    loadingView
                } else if searchViewModel.searchResults.isEmpty {
                    noResultsView
                } else {
                    resultsView
                }
            }
            .navigationTitle(NSLocalizedString("search_title", comment: ""))
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedProduct) { product in
                ProductDetailView(product: product)
                    .environmentObject(authViewModel)
                    .environmentObject(CatalogViewModel())
            }
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: 10) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField(NSLocalizedString("search_placeholder", comment: ""), 
                         text: $searchViewModel.searchQuery)
                    .focused($isSearchFocused)
                    .autocorrectionDisabled()
                    .accessibilityIdentifier("searchField")
                
                if !searchViewModel.searchQuery.isEmpty {
                    Button {
                        searchViewModel.searchQuery = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            if isSearchFocused {
                Button(NSLocalizedString("cancel_button", comment: "")) {
                    searchViewModel.searchQuery = ""
                    isSearchFocused = false
                }
                .transition(.move(edge: .trailing))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .animation(.spring(), value: isSearchFocused)
    }
    
    // MARK: - Recent Searches
    
    private var recentSearchesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !searchViewModel.recentSearches.isEmpty {
                HStack {
                    Text(NSLocalizedString("recent_searches_title", comment: ""))
                        .font(.headline)
                    Spacer()
                    Button(NSLocalizedString("clear_button", comment: "")) {
                        searchViewModel.clearRecentSearches()
                    }
                    .font(.subheadline)
                    .foregroundColor(Color("AppPrimary"))
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                ForEach(searchViewModel.recentSearches, id: \.self) { query in
                    Button {
                        searchViewModel.selectRecentSearch(query)
                    } label: {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(.secondary)
                            Text(query)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.left")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                    Divider().padding(.leading, 48)
                }
            }
            
            // Search tips
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "magnifyingglass.circle.fill")
                    .font(.system(size: 56))
                    .foregroundColor(Color("AppPrimary").opacity(0.4))
                Text(NSLocalizedString("search_hint", comment: ""))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
            Text(NSLocalizedString("searching_text", comment: ""))
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - No Results
    
    private var noResultsView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 56))
                .foregroundColor(.gray)
            Text(String(format: NSLocalizedString("no_results_format", comment: ""),
                        searchViewModel.searchQuery))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Results List
    
    private var resultsView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                Text(String(format: NSLocalizedString("results_count_format", comment: ""),
                            searchViewModel.searchResults.count))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                
                ForEach(searchViewModel.searchResults) { product in
                    SearchResultRow(product: product)
                        .onTapGesture { selectedProduct = product }
                    Divider().padding(.leading, 72)
                }
            }
        }
    }
}

// MARK: - Search Result Row

struct SearchResultRow: View {
    let product: Product
    
    var body: some View {
        HStack(spacing: 14) {
            // Compact album art
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(
                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 52, height: 52)
                Image(systemName: "music.note")
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(product.title)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                Text(product.artist)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Text(product.genre.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color("AppPrimary").opacity(0.15))
                        .foregroundColor(Color("AppPrimary"))
                        .cornerRadius(4)
                    Text(String(product.releaseYear))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(product.formattedPrice)
                    .font(.subheadline.bold())
                    .foregroundColor(Color("AppPrimary"))
                if !product.isInStock {
                    Text(NSLocalizedString("out_of_stock", comment: ""))
                        .font(.caption2)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}
