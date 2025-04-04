import SwiftUI

struct SignUpView: View {
    
    @State var fullname: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State private var showingAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    var isScureField: Bool = false
    @Environment(\.dismiss) private var dismess
    @EnvironmentObject var authViewModel: AuthViewModel
    private let authValidation = AuthValidation()
    
    var body: some View {
        
        ZStack {
            Color(.black)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                
                Button {
                    // Action
                    dismess()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.title)
                        .imageScale(.medium)
                        .padding()
                }
                
                Text("Create new account")
                    .font(.system(size: 40, weight: .semibold))
                    .multilineTextAlignment(.leading)
                    .frame(width: 250)
                
                Spacer()
                
                VStack {
                    VStack(spacing: 52) {
                        CustomInputField(text: $fullname, title: "Full Name", placeholder: "Enter your name")
                        
                        CustomInputField(text: $email, title: "Email Address", placeholder: "name@gmail.com")
                        
                        CustomInputField(text: $password, title: "Create Password", placeholder: "Enter your password", isScureField: true)
                        
                    }// VStack3
                    .padding(.leading)
                    
                    Spacer()
                    
                    if authViewModel.isLoading {
                        LoadingButton(text: "SIGNING UP...")
                    } else {
                        AuthButton(text: "SIGN UP"){
                            let validationResult = authValidation.validateSignupInputs(fullname: fullname, email: email, password: password)
                            if validationResult.0 {
                                authViewModel.registerUser(withEmail: email, password: password, fullname: fullname)
                            } else {
                                alertTitle = validationResult.1
                                alertMessage = validationResult.2
                                showingAlert = true
                            }
                        }
                    }
                    
                    Spacer()
                    
                }// VStack2
                
            }// VStack1
            .foregroundColor(.white)
            .padding(.leading, 5)
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            
        }// ZStack1
        
    }
}

#Preview {
    SignUpView()
}
