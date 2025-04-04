import SwiftUI

struct LoginView: View {
    
    @State var email: String = ""
    @State var password: String = ""
    var isScureField: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showingAlert: Bool = false
    @EnvironmentObject var authViewModel: AuthViewModel
    private let authValidation = AuthValidation()
    
    var body: some View {
        
        NavigationStack {
            
            ZStack {
                Color(.black)
                    .ignoresSafeArea()
                
                VStack {
                    
                    // image and title
                    VStack {
                        Image("Uber-Icon")
                        
                        Text("UBER")
                            .foregroundStyle(.white)
                            .font(.largeTitle)
                    }// VStack2
                    
                    
                    // input fields
                    VStack(spacing: 33) {
                        
                        CustomInputField(text: $email, title: "Email Address", placeholder: "name@gmail.com")
                        
                        CustomInputField(text: $password, title: "Password", placeholder: "Enter your password", isScureField: true)
                        
                        Button {
                            //Action
                        } label: {
                            Text("Forget Password?")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.top)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        
                    }// VStsck3
                    .padding(.horizontal)
                    .padding(.top, 15)
                    
                    
                    // social sign in view
                    VStack {
                        HStack(spacing: 24) {
                            Rectangle()
                                .foregroundColor(.white)
                                .frame(width: 76, height: 1)
                                .opacity(0.5)
                            
                            Text("Sign in with social")
                                .foregroundColor(.white)
                            
                            Rectangle()
                                .foregroundColor(.white)
                                .frame(width: 76, height: 1)
                                .opacity(0.5)
                        }//HStack1
                        
                        HStack(spacing: 24) {
                            Button {
                                //Acton
                            } label: {
                                Image("Facebook-Icon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 36, height: 36)
                            }
                            
                            Button {
                                //Acton
                            } label: {
                                Image("Google-Icon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 36, height: 36)
                            }
                            
                        }//HStack2
                        
                    }// VStack4
                    .padding(.vertical)
                    
                    
                    // sign in button
                    if authViewModel.isLoading {
                        LoadingButton(text: "SIGNING IN...")
                    } else {
                        AuthButton(text: "SIGN IN") {
                            let validationResult = authValidation.validateLoginInputs(email: email, password: password)
                            if validationResult.0 {
                                authViewModel.signIn(withEmail: email, password: password)
                            } else {
                                alertTitle = validationResult.1
                                alertMessage = validationResult.2
                                showingAlert = true
                            }
                        }
                        .padding(.top)
                    }
                    
                    // sign up button
                    NavigationLink(destination: {
                        SignUpView()
                            .navigationBarBackButtonHidden(true)
                    }, label: {
                        HStack{
                            Text("Don't have an account?")
                                .font(.system(size: 14))
                            
                            Text("Sign Up")
                                .font(.system(size: 14, weight: .semibold))
                        }// HStack4
                        .foregroundColor(.white)
                    })
                    .padding(.top, 30)
                    
                    
                }// VStack1
                
            }// ZStack1
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            
        }// NavigationStack
        
        
    }
}

#Preview {
    LoginView()
}
