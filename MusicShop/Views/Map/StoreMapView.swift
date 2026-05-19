import SwiftUI
import MapKit

// MARK: - Store Map View

struct StoreMapView: View {
    
    // MARK: - Environment & State
    
    @EnvironmentObject var mapViewModel: MapViewModel
    @State private var selectedAnnotation: Store?
    @State private var showStoreList: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // MapKit Map
                Map(coordinateRegion: $mapViewModel.region,
                    showsUserLocation: true,
                    annotationItems: mapViewModel.stores) { store in
                    MapAnnotation(coordinate: store.coordinate) {
                        StoreMapPin(
                            store: store,
                            isSelected: selectedAnnotation?.id == store.id
                        ) {
                            withAnimation(.spring()) {
                                selectedAnnotation = store
                                mapViewModel.centerOnStore(store)
                            }
                        }
                    }
                }
                .ignoresSafeArea(edges: .top)
                
                // Bottom controls overlay
                VStack(spacing: 0) {
                    // Store info card (when selected)
                    if let store = selectedAnnotation {
                        StoreInfoCard(store: store) {
                            mapViewModel.openInMaps(store: store)
                        } onDismiss: {
                            withAnimation { selectedAnnotation = nil }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    }
                    
                    // Bottom controls
                    bottomControls
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                }
            }
            .navigationTitle(NSLocalizedString("map_title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation { showStoreList.toggle() }
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                }
            }
            .sheet(isPresented: $showStoreList) {
                StoreListSheet(stores: mapViewModel.stores) { store in
                    showStoreList = false
                    mapViewModel.centerOnStore(store)
                    selectedAnnotation = store
                }
            }
        }
        .onAppear { mapViewModel.requestLocation() }
    }
    
    // MARK: - Bottom Controls
    
    private var bottomControls: some View {
        HStack(spacing: 12) {
            // My location button
            Button {
                mapViewModel.centerOnUser()
            } label: {
                Image(systemName: "location.fill")
                    .font(.system(size: 20))
                    .frame(width: 48, height: 48)
                    .background(.background)
                    .cornerRadius(12)
                    .shadow(radius: 4)
            }
            
            // Nearest store button
            Button {
                mapViewModel.findNearestStore()
                if let nearest = mapViewModel.nearestStore {
                    mapViewModel.centerOnStore(nearest)
                    selectedAnnotation = nearest
                }
            } label: {
                HStack {
                    Image(systemName: "star.fill")
                    Text(NSLocalizedString("nearest_store_button", comment: ""))
                        .font(.subheadline.bold())
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color("AppPrimary"))
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(radius: 4)
            }
            .accessibilityIdentifier("nearestStoreButton")
        }
    }
}

// MARK: - Store Map Pin

struct StoreMapPin: View {
    let store: Store
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color("AppPrimary") : Color.white)
                        .frame(width: isSelected ? 48 : 36, height: isSelected ? 48 : 36)
                        .shadow(radius: isSelected ? 8 : 4)
                    
                    Image(systemName: "music.note.house.fill")
                        .font(.system(size: isSelected ? 22 : 16))
                        .foregroundColor(isSelected ? .white : Color("AppPrimary"))
                }
                
                // Triangle pointer
                Triangle()
                    .fill(isSelected ? Color("AppPrimary") : Color.white)
                    .frame(width: 12, height: 8)
            }
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .animation(.spring(), value: isSelected)
        }
    }
}

// MARK: - Triangle Shape

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Store Info Card

struct StoreInfoCard: View {
    let store: Store
    let onNavigate: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.name)
                        .font(.headline)
                    Text(store.address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 16) {
                Label(store.phone, systemImage: "phone")
                    .font(.caption)
                Label(store.workingHours, systemImage: "clock")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
            
            Button(action: onNavigate) {
                Label(NSLocalizedString("navigate_button", comment: ""), systemImage: "arrow.triangle.turn.up.right.circle.fill")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color("AppPrimary"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(16)
        .background(.background)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.12), radius: 12)
    }
}

// MARK: - Store List Sheet

struct StoreListSheet: View {
    let stores: [Store]
    let onSelect: (Store) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(stores) { store in
                Button {
                    onSelect(store)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(store.name).font(.headline).foregroundColor(.primary)
                        Text(store.address).font(.caption).foregroundColor(.secondary)
                        Label(store.workingHours, systemImage: "clock")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(NSLocalizedString("store_list_title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("close_button", comment: "")) { dismiss() }
                }
            }
        }
    }
}
