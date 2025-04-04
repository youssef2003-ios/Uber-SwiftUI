import SwiftUI
import MapKit

struct AcceptTripView: View {
    
    @State private var region: MKCoordinateRegion
    @EnvironmentObject var homeViewModel: HomeViewModel
    let trip: Trip
    let annotationItem: UberLocation
    
    init(trip: Trip) {
        let center = CLLocationCoordinate2D(latitude: trip.pickupLocation.latitude,
                                            longitude: trip.pickupLocation.longitude)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.025,
                                    longitudeDelta: 0.025)
        
        self.region = MKCoordinateRegion(center: center,
                                         span: span)
        
        self.trip = trip
        
        self.annotationItem = UberLocation(title: trip.pickupLocationName,
                                           address: trip.pickupLocationAddress,
                                           coordinate: trip.pickupLocation.toCoordinate())
    }
    
    var body: some View {
        
        VStack {
            
            Capsule()
                .foregroundColor(Color(.systemGray4))
                .frame(width: 48, height: 6)
                .padding(.top, 8)
            
            // would you like to pickup view
            VStack {
                HStack {
                    Text("Would you like to pickup this passenger?")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(width: 185)
                    
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
                    
                }// Hstack
                
                Divider()
                
            }// VStack2
            .padding()
            
            // user info view
            VStack {
                HStack {
                    Image("Male-profile-photo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(.circle)
                    
                    VStack(alignment: .leading, spacing: 4){
                        Text(trip.passengerName)
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
                
            }// VStack3
            .padding()
            
            // pickup location info view
            VStack {
                // trip location info
                HStack {
                    // address info
                    VStack(alignment: .leading, spacing: 6){
                        Text(trip.pickupLocationName)
                            .font(.headline)
                        
                        Text(trip.pickupLocationAddress)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }//VStack
                    
                    Spacer()
                    
                    // distance
                    VStack {
                        Text("\(trip.distanceToPassenger.distancelMilesString())")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("mi")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }//Vstack
                    
                }//HStack
                .padding(.horizontal)
                
                // map
                Map(coordinateRegion: $region, annotationItems: [annotationItem]) { item in
                    MapMarker(coordinate: item.coordinate)
                }
                .frame(height: 220)
                .cornerRadius(10)
                .padding()
                .shadow(color: .black.opacity(0.6), radius: 10)
                
                Divider()
                
            }// VStack4
            
            // action buttons
            HStack {
                Button {
                    // Action
                    homeViewModel.rejectTrip()
                } label: {
                    Text("Reject")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding()
                        .frame(width: (UIScreen.main.bounds.width / 2) - 32,
                               height: 56)
                        .background(Color(.systemRed))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    
                }
                
                Spacer()
                
                Button {
                    // Action
                    homeViewModel.acceptTrip()
                } label: {
                    Text("Accept")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding()
                        .frame(width: (UIScreen.main.bounds.width / 2) - 32,
                               height: 56)
                        .background(Color(.systemBlue))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
                
            }// HStack
            .padding(.top)
            .padding(.horizontal)
            .padding(.bottom, 24)
            
        }// VStack1
        .background(Color.theme.backgroundColor)
        .cornerRadius(16)
        .shadow(color: Color.theme.secndaryBackgroundColor, radius: 20)
        
    }
}

//#Preview {
//    AcceptTripView()
//}
