import SwiftUI

struct SideMenuView: View {
    
    @State var showingAlert: Bool = false
    @EnvironmentObject var authViewModel: AuthViewModel
    
    private var user: User
    
    init(user: User) {
        self.user = user
    }
    
    var body: some View {
        
        VStack(spacing: 40) {
            
            /// Header view
            VStack(alignment: .leading, spacing: 32) {
                /// User info
                HStack {
                    if user.accountType == .passenger {
                        Image("Male-profile-photo")
                            .resizable()
                            .scaledToFill()
                            .clipShape(.circle)
                            .frame(width: 64, height: 64)
                    } else {
                        Image("driver")
                            .resizable()
                            .scaledToFill()
                            .clipShape(.circle)
                            .frame(width: 64, height: 64)
                    }
        
                    VStack(alignment: .leading, spacing: 8) {
                        Text(user.fullname)
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text(user.email)
                            .font(.system(size: 14))
                            .accentColor(Color.theme.primaryTextColor)
                            .opacity(0.77)
                    }// VStack2
                    
                }// HStack1 (user info)
                
                /// Become a driver
                VStack(alignment: .leading,  spacing: 16) {
                    Text("Do more with yout account")
                        .font(.footnote)
                        .fontWeight(.semibold)
                    
                    Button {
                        // Action
                        showingAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "dollarsign.square")
                                .font(.title2)
                                .imageScale(.medium)
                            
                            Text("Make Money Driving")
                                .font(.system(size: 16, weight: .semibold))
                                .padding(6)
                        }// HStack2
                        .foregroundColor(Color.theme.primaryTextColor)
                    }
                    .disabled(user.accountType == .driver)
                                        
                }// VStack3 (become a driver)
                
                Rectangle()
                    .frame(width: 296, height: 0.75)
                    .opacity(0.7)
                    .foregroundColor(Color(.separator))
                    .shadow(color: .black.opacity(0.7), radius: 4)
                
            }// VStack2 (header view)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
            
            /// Option list
            VStack {
                ForEach(SideMenuOptionViewModel.allCases, id: \.self) { viewModel in
                    NavigationLink(value: viewModel) {
                        SideMenuOptionView(viewModel: viewModel)
                            .padding()
                    }
                    
                }
            }// VStack4 (option list)
            .navigationDestination(for: SideMenuOptionViewModel.self) { viewModel in
                switch viewModel {
                case .trips:
                    Text("trips")
                case .wallet:
                    Text("wallet")
                case .settings:
                    SettingsView(user: user)
                case .messages:
                    Text("messages")
                }
            }
            
            Spacer()
            
        }// VStack1
        .padding(.top, 32)
        .alert("Are you sure to convrt your accout to driver account?", isPresented: $showingAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Convert", role: .destructive) {
                if user.accountType == .passenger {
                    authViewModel.updateAccountType(to: .driver)
                }
            }
        }

        
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews:some View {
        NavigationStack{
            SideMenuView(user: dev.mockUser)
        }
    }
}

