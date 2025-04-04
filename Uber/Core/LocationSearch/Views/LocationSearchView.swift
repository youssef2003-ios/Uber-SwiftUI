import SwiftUI

struct LocationSearchView: View {
    
    @State private var startLocationText = ""
    @EnvironmentObject var viewModel: HomeViewModel
    
    var body: some View {
        
        VStack {
            // Header View
            HStack {
                
                VStack {
                    
                    Circle()
                        .fill(Color(.systemGray3))
                        .frame(width: 6, height: 6)
                    
                    Rectangle()
                        .fill(Color(.systemGray3))
                        .frame(width: 1, height: 24)
                    
                    Rectangle()
                        .fill(Color.theme.primaryTextColor)
                        .frame(width: 6, height: 6)
                    
                } // VStack2
                
                VStack {
                    
                    TextField("Current location", text: $startLocationText)
                        .frame(height: 32)
                        .padding(.leading, 8)
                        .background(Color.theme.textFieldColor)
                        .padding(.trailing)
                    
                    TextField("Where to?", text: $viewModel.queryFregment)
                        .frame(height: 32)
                        .padding(.leading, 8)
                        .background(Color(.systemGray4))
                        .padding(.trailing)
                }// VStack3
                
            }// HStack
            .padding(.horizontal)
            .padding(.top, 64)
            
            Divider()
                .padding(.vertical)
            
            // List View
            LocationSearchResultsView(viewModel: viewModel, config: .ride)
            
        }// VStack1
        .background(Color.theme.backgroundColor)
        
        
    }
}

#Preview {
    LocationSearchView()
}
