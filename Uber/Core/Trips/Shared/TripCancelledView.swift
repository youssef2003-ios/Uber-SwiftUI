import SwiftUI

struct TripCancelledView: View {
    
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    var body: some View {
        
        VStack {
            Capsule()
                .foregroundColor(Color(.systemGray4))
                .frame(width: 48, height: 6)
                .padding(.top, 8)
            
            Text(homeViewModel.tripCancelledMessage)
                .font(.headline)
                .padding(.vertical)
            
            Button {
                // Action
                guard let user = homeViewModel.currentUser else {return}
                guard let trip = homeViewModel.trip else {return}
                
                if user.accountType == .passenger {
                    if trip.state == .driverCancelled {
                        homeViewModel.deleteTrip()
                    } else if trip.state == .passengerCancelled {
                        homeViewModel.trip = nil
                    }
                } else {
                    if trip.state == .passengerCancelled {
                        homeViewModel.deleteTrip()
                    } else if trip.state == .driverCancelled {
                        homeViewModel.trip = nil                        
                    }
                }
                
                // Reset the map state
                homeViewModel.shouldUpdateMap = true
                
            } label: {
                Text("OK")
                    .fontWeight(.bold)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 50)
                    .background(.blue)
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
            
        }// VStack1
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
        .background(Color.theme.backgroundColor)
        .cornerRadius(16)
        .shadow(color: Color.theme.secndaryBackgroundColor, radius: 20)
        
    }
}

//#Preview {
//    TripCancelledView()
//}
