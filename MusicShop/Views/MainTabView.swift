import SwiftUI

// MARK: - Main Tab View

struct MainTabView: View {
    
    // MARK: - State
    
    @State private var selectedTab: Int = 0
    @StateObject private var catalogViewModel = CatalogViewModel()
    @StateObject private var searchViewModel = SearchViewModel()
    @StateObject private var mapViewModel = MapViewModel()
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            CatalogView()
                .environmentObject(catalogViewModel)
                .tabItem {
                    Label(NSLocalizedString("tab_catalog", comment: ""),
                          systemImage: "music.note.list")
                }
                .tag(0)
            
            SearchView()
                .environmentObject(searchViewModel)
                .tabItem {
                    Label(NSLocalizedString("tab_search", comment: ""),
                          systemImage: "magnifyingglass")
                }
                .tag(1)
            
            StoreMapView()
                .environmentObject(mapViewModel)
                .tabItem {
                    Label(NSLocalizedString("tab_map", comment: ""),
                          systemImage: "map.fill")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label(NSLocalizedString("tab_profile", comment: ""),
                          systemImage: "person.circle.fill")
                }
                .tag(3)
        }
        .accentColor(Color("AppPrimary"))
    }
}
