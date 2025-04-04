import SwiftUI

struct TripAcceptedView: View {
    
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    var body: some View {
        
        VStack {
            Capsule()
                .foregroundColor(Color(.systemGray4))
                .frame(width: 48, height: 6)
                .padding(.top, 8)
            
            
            if let trip = homeViewModel.trip {
                
                // pickup info view
                VStack {
                    HStack {
                        Text("Meet your driver at \(trip.pickupLocationName) for your trip to \(trip.dropoffLocationName)")
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
                        
                    }// HStack
                    .padding()
                    
                    Divider()
                    
                }// VStack2
                
                // driver info view
                VStack {
                    HStack {
                        Image("driver")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 70, height: 70)
                            .clipShape(.circle)
                        
                        VStack(alignment: .leading, spacing: 4){
                            Text("\(trip.driverName)")
                                .fontWeight(.semibold)
                            
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
                        
                        // driver vehicle info
                        VStack(alignment: .center) {
                            Image("UberX")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 64)
                            
                            
                            HStack(alignment: .center) {
                                Text("Mercedes $ -")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray)
                                
                                Text("5G432K")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .frame(width: 160)
                            .padding(.bottom)
                            
                        }// VStack
                        
                    }// HStack
                    
                    Divider()
                    
                }// VStack3
                .padding()
                
            }// if

            Button {
                // Action
                homeViewModel.cancelTripAsPassenger()
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
//    TripAcceptedView()
//}
