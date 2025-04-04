import SwiftUI

struct SettingsView: View {
    
    private let user: User
    @State private var refreshID = UUID()
    @State private var alertMessage: String = ""
    @State private var showingSignOutAlert: Bool = false
    @State private var showingErrorAlert: Bool = false
    @EnvironmentObject var authViewModel: AuthViewModel
    
    init(user: User) {
        self.user = user
    }
    
    var body: some View {
        
        VStack {
            
            List {
                
                Section {
                    // user info header
                    HStack {
                        Image("Male-profile-photo")
                            .resizable()
                            .scaledToFill()
                            .clipShape(.circle)
                            .frame(width: 64, height: 64)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(user.fullname)
                                .font(.system(size: 16, weight: .semibold))
                            
                            Text(user.email)
                                .font(.system(size: 14))
                                .accentColor(Color.theme.primaryTextColor)
                                .opacity(0.77)
                        }// VStack
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .imageScale(.small)
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                    }// HStack1 (user info)
                    .padding(8 )
                }// Section1
                
                
                Section("Favorites") {
                    ForEach(SavedLocationViewModel.allCases) { viewModel in
                        NavigationLink {
                            SavedLocationSearchView(config: viewModel)
                                .onDisappear {
                                    // Refresh view when returning from search view
                                    refreshID = UUID()
                                }
                        } label: {
                            SavedLocationRowView(viewModel: viewModel, user: user)
                        }
                        
                    }// ForEach
                    
                }// Section2
                
                Section("Settings") {
                    SettingsRowView(imageName: "bell.circle.fill", title: "Notifications", tintColor:  Color(.systemPurple))
                    
                    
                    SettingsRowView(imageName: "creditcard.circle.fill", title: "Payment Methods", tintColor:  Color(.systemBlue))
                    
                }// Section3
                
                Section("Account") {
                    SettingsRowView(imageName: "dollarsign.square.fill", title: "Make Money Driving", tintColor:  Color(.systemGreen))
                    
                    
                    SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor:  Color(.systemRed))
                        .onTapGesture {
                            showingSignOutAlert = true
                        }
                    
                }// Section4
                
            }// List
            .id(refreshID) // Force refresh when ID changes
            
        }// VStack1
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .alert("Are you sure you want to sign out?", isPresented: $showingSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                authViewModel.signOut { error in
                    if let error = error {
                        alertMessage = error.localizedDescription
                        showingErrorAlert = true
                    }
                }
            }
        }
        .alert("Error in sign out", isPresented: $showingErrorAlert, actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text(alertMessage)
        })
        
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews:some View {
        NavigationStack{
            SideMenuView(user: dev.mockUser)
        }
    }
}
