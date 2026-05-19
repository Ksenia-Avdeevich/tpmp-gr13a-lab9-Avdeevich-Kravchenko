import SwiftUI

// MARK: - Catalog View

struct CatalogView: View {
    
    // MARK: - Environment & State
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var catalogViewModel: CatalogViewModel
    @State private var showDetail: Bool = false
    @State private var selectedProduct: Product?
    @State private var dragOffset: CGSize = .zero
    @State private var showFavoritesOnly: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Genre filter
                genreFilterBar
                
                if catalogViewModel.isLoading {
                    Spacer()
                    ProgressView(NSLocalizedString("loading_text", comment: ""))
                    Spacer()
                } else if catalogViewModel.filteredProducts.isEmpty {
                    emptyState
                } else {
                    // Swipeable card view
                    swipeableCard
                    
                    // Progress indicator
                    progressIndicator
                    
                    // Navigation buttons
                    navigationButtons
                }
            }
            .navigationTitle(NSLocalizedString("catalog_title", comment: ""))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation { showFavoritesOnly.toggle() }
                        if showFavoritesOnly, let userId = authViewModel.currentUser?.id {
                            catalogViewModel.loadFavorites(userId: userId)
                        } else {
                            catalogViewModel.loadProducts()
                        }
                    } label: {
                        Image(systemName: showFavoritesOnly ? "heart.fill" : "heart")
                            .foregroundColor(showFavoritesOnly ? .red : .primary)
                    }
                    .accessibilityIdentifier("favoritesButton")
                }
            }
        }
        .onAppear { catalogViewModel.loadProducts() }
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(product: product)
                .environmentObject(authViewModel)
                .environmentObject(catalogViewModel)
        }
    }
    
    // MARK: - Genre Filter Bar
    
    private var genreFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(catalogViewModel.availableGenres, id: \.self) { genre in
                    GenreChip(
                        title: genre == "All" ? NSLocalizedString("genre_all", comment: "") : genre,
                        isSelected: catalogViewModel.selectedGenre == genre
                    ) {
                        withAnimation(.spring()) {
                            catalogViewModel.selectedGenre = genre
                            catalogViewModel.currentIndex = 0
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Swipeable Card
    
    private var swipeableCard: some View {
        let products = catalogViewModel.filteredProducts
        let index = catalogViewModel.currentIndex
        guard index < products.count else { return AnyView(EmptyView()) }
        
        return AnyView(
            ZStack {
                // Background cards (peek effect)
                if index + 1 < products.count {
                    ProductCardView(product: products[index + 1])
                        .scaleEffect(0.93)
                        .offset(y: 16)
                        .opacity(0.6)
                }
                
                // Main card with gesture
                ProductCardView(product: products[index])
                    .offset(x: dragOffset.width)
                    .rotationEffect(.degrees(Double(dragOffset.width / 30)))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation
                            }
                            .onEnded { value in
                                handleSwipe(translation: value.translation)
                            }
                    )
                    .onTapGesture {
                        selectedProduct = products[index]
                    }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
        )
    }
    
    // MARK: - Progress Indicator
    
    private var progressIndicator: some View {
        let total = catalogViewModel.filteredProducts.count
        let current = catalogViewModel.currentIndex + 1
        return HStack(spacing: 4) {
            Text("\(current) / \(total)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.top, 12)
    }
    
    // MARK: - Navigation Buttons
    
    private var navigationButtons: some View {
        HStack(spacing: 32) {
            Button {
                withAnimation(.spring()) { catalogViewModel.swipePrevious() }
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(catalogViewModel.currentIndex == 0 ? .gray : Color("AppPrimary"))
            }
            .disabled(catalogViewModel.currentIndex == 0)
            
            Button {
                selectedProduct = catalogViewModel.filteredProducts[safe: catalogViewModel.currentIndex]
            } label: {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(Color("AppPrimary"))
            }
            
            Button {
                withAnimation(.spring()) { catalogViewModel.swipeNext() }
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(
                        catalogViewModel.currentIndex >= catalogViewModel.filteredProducts.count - 1
                            ? .gray : Color("AppPrimary")
                    )
            }
            .disabled(catalogViewModel.currentIndex >= catalogViewModel.filteredProducts.count - 1)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text(NSLocalizedString("no_products_text", comment: ""))
                .foregroundColor(.secondary)
            Spacer()
        }
    }
    
    // MARK: - Swipe Handler
    
    private func handleSwipe(translation: CGSize) {
        let threshold: CGFloat = 100
        withAnimation(.spring()) {
            if translation.width < -threshold {
                catalogViewModel.swipeNext()
            } else if translation.width > threshold {
                catalogViewModel.swipePrevious()
            }
            dragOffset = .zero
        }
    }
}

// MARK: - Genre Chip

struct GenreChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.bold())
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color("AppPrimary") : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// MARK: - Array Safe Index

extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
}
