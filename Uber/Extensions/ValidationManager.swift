import Foundation

struct ValidationManager {
    
    static func validateInputs(email: String, password: String, fullname: String? = nil) -> (Bool, String?, String?) {
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
        
        // Check for empty fullname (only for sign-up)
        if let fullname = fullname, fullname.trimmingCharacters(in: .whitespaces).isEmpty {
            return (false, "Invalid Input", "Please enter your full name")
        }
        
        return (true, nil, nil)
    }
    
    // Email validation function
    private static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
