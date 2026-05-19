import SwiftUI

// MARK: - Product Detail View

struct ProductDetailView: View {
    
    // MARK: - Properties
    
    let product: Product
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var catalogViewModel: CatalogViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isFavorite: Bool = false
    @State private var scale: CGFloat = 1.0
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Album image with pinch zoom gesture
                    albumImage
                    
                    // Details
                    detailsSection
                    
                    // Add to favorites
                    favoriteButton
                }
            }
            .navigationTitle(product.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("close_button", comment: "")) { dismiss() }
                }
            }
            .onAppear {
                if let userId = authViewModel.currentUser?.id {
                    isFavorite = catalogViewModel.isFavorite(product: product, userId: userId)
                }
            }
        }
    }
    
    // MARK: - Album Image
    
    private var albumImage: some View {
        ZStack {
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 16) {
                Image(systemName: "opticaldisc")
                    .font(.system(size: 120))
                    .foregroundColor(.white.opacity(0.5))
                
                Image(systemName: "music.quarternote.3")
                    .font(.system(size: 48))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(height: 300)
        .scaleEffect(scale)
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    scale = min(max(value, 0.8), 2.5)
                }
                .onEnded { _ in
                    withAnimation(.spring()) { scale = 1.0 }
                }
        )
        .ignoresSafeArea(edges: .top)
        .accessibilityIdentifier("albumImage")
    }
    
    // MARK: - Details Section
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title and artist
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.title2.bold())
                Text(product.artist)
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            // Price and stock
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(NSLocalizedString("price_label", comment: ""))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(product.formattedPrice)
                        .font(.title2.bold())
                        .foregroundColor(Color("AppPrimary"))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(NSLocalizedString("in_stock_label", comment: ""))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(product.quantity) \(NSLocalizedString("pieces_suffix", comment: ""))")
                        .font(.headline)
                        .foregroundColor(product.isInStock ? .green : .red)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Info grid
            infoGrid
            
            if !product.description.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text(NSLocalizedString("description_label", comment: ""))
                        .font(.headline)
                    Text(product.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var infoGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            InfoCell(icon: "music.note", label: NSLocalizedString("genre_label", comment: ""),
                     value: product.genre.rawValue)
            InfoCell(icon: "calendar", label: NSLocalizedString("year_label", comment: ""),
                     value: String(product.releaseYear))
        }
    }
    
    // MARK: - Favorite Button
    
    private var favoriteButton: some View {
        Button {
            if let userId = authViewModel.currentUser?.id {
                withAnimation(.spring()) {
                    isFavorite = catalogViewModel.toggleFavorite(product: product, userId: userId)
                    // toggleFavorite returns Void, update from DB
                    isFavorite = catalogViewModel.isFavorite(product: product, userId: userId)
                }
            }
        } label: {
            HStack {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                Text(isFavorite
                     ? NSLocalizedString("remove_favorite", comment: "")
                     : NSLocalizedString("add_favorite", comment: ""))
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(isFavorite ? Color.red : Color("AppPrimary"))
            .foregroundColor(.white)
            .cornerRadius(14)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .accessibilityIdentifier("favoriteButton")
    }
    
    // MARK: - Computed
    
    private var gradientColors: [Color] {
        switch product.genre {
        case .rock: return [Color(hex: "1a1a2e"), Color(hex: "e94560")]
        case .pop: return [Color(hex: "ff6b6b"), Color(hex: "feca57")]
        case .jazz: return [Color(hex: "2d3561"), Color(hex: "c05c7e")]
        case .classical: return [Color(hex: "4a4e69"), Color(hex: "c9ada7")]
        case .electronic: return [Color(hex: "0f3460"), Color(hex: "533483")]
        case .hiphop: return [Color(hex: "232526"), Color(hex: "414345")]
        case .country: return [Color(hex: "8b4513"), Color(hex: "d2691e")]
        case .blues: return [Color(hex: "1f4068"), Color(hex: "1b262c")]
        }
    }
}

// MARK: - Info Cell

struct InfoCell: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(Color("AppPrimary"))
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.caption).foregroundColor(.secondary)
                Text(value).font(.subheadline.bold())
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
