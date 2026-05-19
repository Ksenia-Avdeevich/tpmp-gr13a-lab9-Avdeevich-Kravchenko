import SwiftUI

// MARK: - Profile View

struct ProfileView: View {
    
    // MARK: - Environment & State
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showLogoutConfirm: Bool = false
    @State private var selectedLanguage: String = UserDefaultsService.shared.selectedLanguage
    @State private var isDarkMode: Bool = UserDefaultsService.shared.isDarkMode
    @State private var showAbout: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                // User info section
                userInfoSection
                
                // Preferences section
                preferencesSection
                
                // App info section
                appInfoSection
                
                // Logout section
                logoutSection
            }
            .navigationTitle(NSLocalizedString("profile_title", comment: ""))
            .navigationBarTitleDisplayMode(.large)
            .confirmationDialog(
                NSLocalizedString("logout_confirm_title", comment: ""),
                isPresented: $showLogoutConfirm,
                titleVisibility: .visible
            ) {
                Button(NSLocalizedString("logout_button", comment: ""), role: .destructive) {
                    authViewModel.logout()
                }
                Button(NSLocalizedString("cancel_button", comment: ""), role: .cancel) {}
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
        }
    }
    
    // MARK: - User Info Section
    
    private var userInfoSection: some View {
        Section {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color("AppPrimary").gradient)
                        .frame(width: 64, height: 64)
                    Text(String(authViewModel.currentUser?.username.prefix(1).uppercased() ?? "?"))
                        .font(.title.bold())
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(authViewModel.currentUser?.username ?? "-")
                        .font(.headline)
                    Text(authViewModel.currentUser?.email ?? "-")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label(
                        authViewModel.currentUser?.role == .manager
                            ? NSLocalizedString("role_manager", comment: "")
                            : NSLocalizedString("role_buyer", comment: ""),
                        systemImage: authViewModel.currentUser?.role == .manager
                            ? "person.badge.key.fill" : "person.fill"
                    )
                    .font(.caption)
                    .foregroundColor(
                        authViewModel.currentUser?.role == .manager ? .orange : .blue
                    )
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text(NSLocalizedString("profile_section_user", comment: ""))
        }
    }
    
    // MARK: - Preferences Section
    
    private var preferencesSection: some View {
        Section {
            // Language picker
            Picker(NSLocalizedString("language_label", comment: ""),
                   selection: $selectedLanguage) {
                Text("Русский").tag("ru")
                Text("English").tag("en")
                Text("Беларуская").tag("be")
            }
            .onChange(of: selectedLanguage) { newValue in
                UserDefaultsService.shared.selectedLanguage = newValue
            }
            
            // Dark mode toggle
            Toggle(NSLocalizedString("dark_mode_label", comment: ""), isOn: $isDarkMode)
                .onChange(of: isDarkMode) { newValue in
                    UserDefaultsService.shared.isDarkMode = newValue
                }
                .accessibilityIdentifier("darkModeToggle")
        } header: {
            Text(NSLocalizedString("profile_section_preferences", comment: ""))
        }
    }
    
    // MARK: - App Info Section
    
    private var appInfoSection: some View {
        Section {
            Button {
                showAbout = true
            } label: {
                Label(NSLocalizedString("about_app_label", comment: ""),
                      systemImage: "info.circle")
                    .foregroundColor(.primary)
            }
            
            HStack {
                Label(NSLocalizedString("version_label", comment: ""),
                      systemImage: "app.badge")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        } header: {
            Text(NSLocalizedString("profile_section_app", comment: ""))
        }
    }
    
    // MARK: - Logout Section
    
    private var logoutSection: some View {
        Section {
            Button(role: .destructive) {
                showLogoutConfirm = true
            } label: {
                Label(NSLocalizedString("logout_button", comment: ""), systemImage: "rectangle.portrait.and.arrow.right")
            }
            .accessibilityIdentifier("logoutButton")
        }
    }
}

// MARK: - About View

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "music.note.house.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color("AppPrimary"))
                        .padding(.top, 32)
                    
                    Text("MusicShop")
                        .font(.largeTitle.bold())
                    
                    Text("Version 1.0.0")
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text(NSLocalizedString("about_description", comment: ""))
                            .multilineTextAlignment(.center)
                        
                        Divider()
                        
                        HStack {
                            Text(NSLocalizedString("about_team_title", comment: "")).bold()
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Ксения Авдеевич", systemImage: "person.fill")
                            Label("Кравченко Ирина", systemImage: "person.fill")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        Text("Группа 13 · ТПМП 2025–2026")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationTitle(NSLocalizedString("about_app_label", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("close_button", comment: "")) { dismiss() }
                }
            }
        }
    }
}
