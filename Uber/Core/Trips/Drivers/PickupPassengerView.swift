import SwiftUI

struct PickupPassengerView: View {
    
    let trip: Trip
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    var body: some View {
        
        VStack {
            Capsule()
                .foregroundColor(Color(.systemGray4))
                .frame(width: 48, height: 6)
                .padding(.top, 8)
            
            // would you like to pickup view
            VStack {
                HStack {
                    Text("Pickup \(trip.passengerName) at \(trip.dropoffLocationName)")
                        .font(.headline)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .padding(.trailing)
                    
                    Spacer()
                    
                    VStack {
                        Text("\(trip.travelTimeToPassenger)")
                            .bold()
                        
                        Text("min")
                            .bold()
                    }//Vstack
                    .frame(width: 56, height: 56)
                    .foregroundColor(.white)
                    .background(Color(.systemBlue))
                    .cornerRadius(10)
                }
                .padding()
                
                Divider()
                
            }// VStack2
            
            // user info view
            VStack {
                HStack {
                    Image("Male-profile-photo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(.circle)
                    
                    VStack(alignment: .leading, spacing: 4){
                        Text("\(trip.passengerName)")
                            .fontWeight(.bold)
                        
                        HStack{
                            Image(systemName: "star.fill")
                                .foregroundColor(Color(.systemYellow))
                                .imageScale(.small)
                            
                            Text("4.8")
                                .font(.footnote)
                                .foregroundColor(Color(.systemGray))
                        }//HStack
                        
                    }//VStack
                    
                    Spacer()
                    
                    VStack(spacing: 6) {
                        Text("Earnings")
                            .foregroundColor(Color(.systemGray))
                        
                        Text(trip.tripCost.toCurrancy())
                            .font(.system(size: 24, weight: .semibold))
                    }//VStack
                    
                }// HStack
                
                Divider()
                
            }// VStack2
            .padding()
            
            Button {
                // Action
                homeViewModel.cancelTripAsDriver()
            } label: {
                Text("CANCEL TRIP")
                    .fontWeight(.bold)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 50)
                    .background(.red)
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
            
            
        }// VStack1
        .padding(.bottom, 24)
        .background(Color.theme.backgroundColor)
        .cornerRadius(16)
        .shadow(color: Color.theme.secndaryBackgroundColor, radius: 20)
        
    }
}

//#Preview {
//    PickupPassengerView()
//}
