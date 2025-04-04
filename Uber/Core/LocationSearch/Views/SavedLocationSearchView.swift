
import SwiftUI

struct SavedLocationSearchView: View {
    
    @StateObject var viewModel = HomeViewModel()
    @Environment(\.presentationMode) var presentationMode
    let config: SavedLocationViewModel
    
    var body: some View {
        
        VStack {
            
            TextField("Search for a location...", text: $viewModel.queryFregment)
                .frame(height: 32)
                .padding(.leading)
                .background(Color(.systemGray5))
                .padding()
            
            Spacer()
            
            LocationSearchResultsView(viewModel: viewModel, config: .saveLocation(config))
            
        }// Vstack1
        .navigationTitle(config.subTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(viewModel.$dismissSearchView) { shouldDismiss in
            if shouldDismiss {
                presentationMode.wrappedValue.dismiss()
                viewModel.resetDismissSearchView()
                
                // Add a slight delay to ensure Firebase update completes
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    // This will force UserService to refresh user data
                    NotificationCenter.default.post(name: NSNotification.Name("RefreshUserData"), object: nil)
                }
            }
        }
        
        
    }
}

#Preview {
    NavigationStack{
        SavedLocationSearchView(config: .home)
    }
}
