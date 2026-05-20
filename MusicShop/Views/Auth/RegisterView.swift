import SwiftUI

struct RegisterView: View {

    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @FocusState private var focusedField: Field?

    private enum Field { case username, email, password, confirmPassword }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 56))
                        .foregroundColor(Color("AppPrimary"))
                    Text(NSLocalizedString("register_title", comment: ""))
                        .font(.title.bold())
                }
                .padding(.top, 20)

                // Form fields
                VStack(spacing: 16) {

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
                            .onSubmit { focusedField = .email }
                            .accessibilityIdentifier("registerUsernameField")  // ← тест ищет это
                    }

                    // Email
                    VStack(alignment: .leading, spacing: 6) {
                        Label(NSLocalizedString("email_label", comment: ""), systemImage: "envelope")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        TextField("user@example.com", text: $email)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .focused($focusedField, equals: .email)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .password }
                            .accessibilityIdentifier("registerEmailField")  // ← тест ищет это
                    }

                    // Password
                    VStack(alignment: .leading, spacing: 6) {
                        Label(NSLocalizedString("password_label", comment: ""), systemImage: "lock")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        SecureField(NSLocalizedString("password_placeholder", comment: ""), text: $password)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .focused($focusedField, equals: .password)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .confirmPassword }
                            .accessibilityIdentifier("registerPasswordField")  // ← тест ищет это
                    }

                    // Confirm Password
                    VStack(alignment: .leading, spacing: 6) {
                        Label(NSLocalizedString("confirm_password_label", comment: ""), systemImage: "lock.fill")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        SecureField(NSLocalizedString("confirm_password_placeholder", comment: ""), text: $confirmPassword)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .focused($focusedField, equals: .confirmPassword)
                            .submitLabel(.go)
                            .onSubmit { handleRegister() }
                            .accessibilityIdentifier("registerConfirmPasswordField")  // ← тест ищет это
                    }
                }

                // Error
                if !authViewModel.errorMessage.isEmpty {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text(authViewModel.errorMessage)
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
                    .transition(.opacity)
                    .accessibilityIdentifier("registerErrorText")
                }

                // Register button
                Button {
                    handleRegister()
                } label: {
                    HStack {
                        if authViewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text(NSLocalizedString("register_button", comment: ""))
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
                .accessibilityIdentifier("registerButton")  // ← тест ищет это

                Button(NSLocalizedString("have_account_link", comment: "")) {
                    dismiss()
                }
                .foregroundColor(Color("AppPrimary"))
                .padding(.bottom, 32)
                .accessibilityIdentifier("backToLoginButton")
            }
            .padding(.horizontal, 24)
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle(NSLocalizedString("register_title", comment: ""))
    }

    private func handleRegister() {
        focusedField = nil
        authViewModel.register(
            username: username,
            email: email,
            password: password,
            confirmPassword: confirmPassword
        )
    }
}
