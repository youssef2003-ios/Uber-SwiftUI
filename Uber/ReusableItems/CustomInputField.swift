import SwiftUI

struct CustomInputField: View {
    
    @Binding var text: String
    let title: String
    let placeholder: String
    var isScureField: Bool = false
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            if isScureField {
                SecureField(placeholder, text: $text)
                    .foregroundColor(.white)
                    .placeholder(when: text.isEmpty) {
                        Text(placeholder)
                            .foregroundColor(.gray.opacity(0.23))
                    }
            } else {
                TextField(placeholder, text: $text)
                    .foregroundColor(.white)
                    .placeholder(when: text.isEmpty) {
                        Text(placeholder)
                            .foregroundColor(.gray.opacity(0.23))
                    }
            }
            
            Rectangle()
                .foregroundColor(Color(.init(white: 1, alpha: 0.3)))
                .frame(width: UIScreen.main.bounds.width - 32, height: 0.7)
        }
        
    }
}

// MARK: - Placeholder Modifier

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// MARK: - Authentication Validation

class AuthValidation {
    // Basic validation for both login and signup
    func validateBasicInputs(email: String, password: String) -> (Bool, String, String) {
        // Check for empty email
        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            return (false, "Invalid Input", "Please enter your email address")
        }
        
        // Validate email format
        if !isValidEmail(email) {
            return (false, "Invalid Email", "Please enter a valid email address")
        }
        
        // Check for empty password
        if password.trimmingCharacters(in: .whitespaces).isEmpty {
            return (false, "Invalid Input", "Please enter your password")
        }
        
        // Check password length - must be at least 6 characters
        if password.count < 6 {
            return (false, "Invalid Password", "Password must be at least 6 characters")
        }
        
        return (true, "", "")
    }
    
    // Login validation
    func validateLoginInputs(email: String, password: String) -> (Bool, String, String) {
        return validateBasicInputs(email: email, password: password)
    }
    
    // Signup validation
    func validateSignupInputs(fullname: String, email: String, password: String) -> (Bool, String, String) {
        // Check for empty name
        if fullname.trimmingCharacters(in: .whitespaces).isEmpty {
            return (false, "Invalid Input", "Please enter your full name")
        }
        
        // Perform basic validation (email and password)
        return validateBasicInputs(email: email, password: password)
    }
    
    // Email validation function
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

// MARK: - Common UI Components

struct AuthButton: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .foregroundColor(.black)
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.black)
            }
            .frame(width: UIScreen.main.bounds.width - 32, height: 50)
        }
        .background(.white)
        .cornerRadius(10)
    }
}


#Preview {
    CustomInputField( text: .constant(""), title: "Email Address", placeholder: "name@gmail.com")
}
