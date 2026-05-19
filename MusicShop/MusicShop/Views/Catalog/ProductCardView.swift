import SwiftUI

// MARK: - Product Card View

struct ProductCardView: View {
    
    let product: Product
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Album cover image
            albumCover
            
            // Product info
            productInfo
        }
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.12), radius: 16, y: 8)
    }
    
    // MARK: - Album Cover
    
    private var albumCover: some View {
        ZStack(alignment: .topTrailing) {
            // Image placeholder with gradient
            RoundedRectangle(cornerRadius: 0)
                .fill(
                    LinearGradient(
                        colors: colorFor(genre: product.genre),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 260)
                .overlay {
                    VStack {
                        Image(systemName: "opticaldisc")
                            .font(.system(size: 80))
                            .foregroundColor(.white.opacity(0.4))
                        Image(systemName: "music.note")
                            .font(.system(size: 36))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            
            // Genre badge
            Text(product.genre.rawValue)
                .font(.caption.bold())
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .padding(12)
            
            // Stock badge
            if !product.isInStock {
                VStack {
                    Spacer()
                    HStack {
                        Text(NSLocalizedString("out_of_stock", comment: ""))
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    
    // MARK: - Product Info
    
    private var productInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(product.title)
                .font(.title3.bold())
                .lineLimit(2)
            
            Text(product.artist)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text(product.formattedPrice)
                    .font(.headline)
                    .foregroundColor(Color("AppPrimary"))
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "shippingbox.fill")
                        .font(.caption)
                    Text("\(product.quantity)")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            Text(String(product.releaseYear))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
    }
    
    // MARK: - Genre Colors
    
    private func colorFor(genre: Product.Genre) -> [Color] {
        switch genre {
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

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
