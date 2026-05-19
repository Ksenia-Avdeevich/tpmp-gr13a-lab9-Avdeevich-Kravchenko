import SwiftUI

// MARK: - Register View

struct RegisterView: View {
    
    // MARK: - State
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showPassword: Bool = false
    @FocusState private var focusedField: Field?
    
    private enum Field { case username, email, password, confirmPassword }
    
    // MARK: - Body
    
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
                
                // Form
                VStack(spacing: 16) {
                    MSTextField(
                        title: NSLocalizedString("username_label", comment: ""),
                        icon: "person",
                        placeholder: NSLocalizedString("username_placeholder", comment: ""),
                        text: $username,
                        focusedField: $focusedField,
                        field: .username,
                        nextField: .email
                    )
                    .accessibilityIdentifier("registerUsernameField")
                    
                    MSTextField(
                        title: NSLocalizedString("email_label", comment: ""),
                        icon: "envelope",
                        placeholder: "user@example.com",
                        text: $email,
                        focusedField: $focusedField,
                        field: .email,
                        nextField: .password,
                        keyboardType: .emailAddress
                    )
                    .accessibilityIdentifier("registerEmailField")
                    
                    MSTextField(
                        title: NSLocalizedString("password_label", comment: ""),
                        icon: "lock",
                        placeholder: NSLocalizedString("password_placeholder", comment: ""),
                        text: $password,
                        focusedField: $focusedField,
                        field: .password,
                        nextField: .confirmPassword,
                        isSecure: true
                    )
                    .accessibilityIdentifier("registerPasswordField")
                    
                    MSTextField(
                        title: NSLocalizedString("confirm_password_label", comment: ""),
                        icon: "lock.fill",
                        placeholder: NSLocalizedString("confirm_password_placeholder", comment: ""),
                        text: $confirmPassword,
                        focusedField: $focusedField,
                        field: .confirmPassword,
                        isSecure: true
                    )
                    .accessibilityIdentifier("registerConfirmPasswordField")
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
                }
                
                // Register button
                Button {
                    authViewModel.register(
                        username: username,
                        email: email,
                        password: password,
                        confirmPassword: confirmPassword
                    )
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
                .accessibilityIdentifier("registerButton")
                
                Button(NSLocalizedString("have_account_link", comment: "")) {
                    dismiss()
                }
                .foregroundColor(Color("AppPrimary"))
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle(NSLocalizedString("register_title", comment: ""))
    }
}

// MARK: - Reusable TextField Component

struct MSTextField: View {
    let title: String
    let icon: String
    let placeholder: String
    @Binding var text: String
    var focusedField: FocusState<RegisterView.Field?>.Binding? = nil
    var field: RegisterView.Field? = nil
    var nextField: RegisterView.Field? = nil
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.caption.bold())
                .foregroundColor(.secondary)
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}
