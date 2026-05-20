import SwiftUI

struct LoginView: View {

    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var showRegister: Bool = false
    @FocusState private var focusedField: Field?

    private enum Field { case username, password }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color("AppPrimary"), Color("AppSecondary")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        logoSection
                        formCard
                        registerButton
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                }
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
        }
    }

    // MARK: - Logo

    private var logoSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "music.note.house.fill")
                .font(.system(size: 72))
                .foregroundColor(.white)
                .shadow(radius: 8)
            Text(NSLocalizedString("app_name", comment: ""))
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(NSLocalizedString("app_tagline", comment: ""))
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
    }

    // MARK: - Form Card

    private var formCard: some View {
        VStack(spacing: 20) {
            Text(NSLocalizedString("login_title", comment: ""))
                .font(.title2.bold())
                .frame(maxWidth: .infinity, alignment: .leading)

            // Username
            VStack(alignment: .leading, spacing: 6) {
                Label(NSLocalizedString("username_label", comment: ""), systemImage: "person")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)

                TextField(NSLocalizedString("username_placeholder", comment: ""), text: $username)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($focusedField, equals: .username)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }
                    .accessibilityIdentifier("usernameField")  // ← ключевой идентификатор
            }

            // Password
            VStack(alignment: .leading, spacing: 6) {
                Label(NSLocalizedString("password_label", comment: ""), systemImage: "lock")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)

                HStack {
                    Group {
                        if showPassword {
                            TextField(NSLocalizedString("password_placeholder", comment: ""), text: $password)
                                .accessibilityIdentifier("passwordFieldVisible")
                        } else {
                            SecureField(NSLocalizedString("password_placeholder", comment: ""), text: $password)
                                .accessibilityIdentifier("passwordField")  // ← ключевой идентификатор
                        }
                    }
                    .focused($focusedField, equals: .password)
                    .submitLabel(.go)
                    .onSubmit { handleLogin() }

                    Button {
                        showPassword.toggle()
                    } label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.secondary)
                    }
                    .accessibilityIdentifier("showPasswordButton")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }

            // Error message
            if !authViewModel.errorMessage.isEmpty {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text(authViewModel.errorMessage)
                }
                .font(.caption)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.opacity)
                .accessibilityIdentifier("errorText")  // ← для теста ошибки
            }

            // Login button
            Button {
                handleLogin()
            } label: {
                HStack {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                    } else {
                        Text(NSLocalizedString("login_button", comment: ""))
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color("AppPrimary"))
                .foregroundColor(.white)
                .cornerRadius(14)
            }
            .disabled(authViewModel.isLoading)
            .accessibilityIdentifier("loginButton")  // ← ключевой идентификатор
        }
        .padding(24)
        .background(.background)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 16, y: 8)
    }

    // MARK: - Register Button

    private var registerButton: some View {
        HStack {
            Text(NSLocalizedString("no_account_text", comment: ""))
                .foregroundColor(.white.opacity(0.8))
            Button(NSLocalizedString("register_link", comment: "")) {
                showRegister = true
            }
            .foregroundColor(.white)
            .fontWeight(.bold)
            .accessibilityIdentifier("goToRegisterButton")  // ← для навигации на регистрацию
        }
        .font(.subheadline)
        .padding(.bottom, 32)
    }

    // MARK: - Actions

    private func handleLogin() {
        focusedField = nil
        authViewModel.login(username: username, password: password)
    }
}
