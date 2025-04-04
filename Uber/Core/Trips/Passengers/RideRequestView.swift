import SwiftUI

struct RideRequestView: View {
    
    @State private var selectedRideType: RideType = .uberX
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    var body: some View {
        
        VStack {
            
            Capsule()
                .foregroundColor(Color(.systemGray4))
                .frame(width: 48, height: 6)
                .padding(.top, 8)
            
            // trip info view
            HStack {
                
                VStack {
                    
                    Circle()
                        .fill(Color(.systemGray3))
                        .frame(width: 8, height: 8)
                    
                    Rectangle()
                        .fill(Color(.systemGray3))
                        .frame(width: 1, height: 32)
                    
                    Rectangle()
                        .fill(Color.theme.primaryTextColor)
                        .frame(width: 8, height: 8 )
                    
                } // VStack2
                
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Text("Current location")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text(homeViewModel.pickupTime ?? "")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 10)
                    
                    HStack {
                        if let location = homeViewModel.selectedUberLocation {
                            Text(location.title)
                                .font(.system(size: 16, weight: .semibold))
                        }
                        
                        Spacer()
                        
                        Text(homeViewModel.dropOffTime ?? "")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    
                }// VStack3
                .padding(.leading, 8)
                
            }// HStack
            .padding()
            
            Divider()
            
            // ride type selection view
            Text ("SUGGESTED RIDES")
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding()
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(RideType.allCases) { type in
                        
                        VStack(alignment: .leading) {
                            Image(type.imageName)
                                .resizable()
                                .scaledToFit()
                            
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(type.description)
                                    .font(.system(size: 14, weight: .semibold))
                                
                                Text(homeViewModel.computeRidePrice(forType: type).toCurrancy())
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .padding()
                            
                        }// VStack
                        .frame(width: 112, height: 140)
                        .foregroundColor(type == selectedRideType ? Color.theme.textColor : Color.theme.primaryTextColor)
                        .background(type == selectedRideType ? .blue :  Color.theme.secndaryBackgroundColor)
                        .scaleEffect(type == selectedRideType ? 1.13 : 1.0)
                        .cornerRadius(10)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedRideType = type
                            }
                        }
                        
                    }// ForEach
                    
                }// HStack
                
            }// ScrollView
            .padding(.horizontal)
            
            Divider()
                .padding(.vertical, 8)
            
            // payment option view
            HStack {
                Text("Visa")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(6)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(5)
                    .padding(.leading)
                
                Text("****1234")
                    .fontWeight(.bold)
                Spacer()
                
                Image(systemName: "chevron.right")
                    .imageScale(.medium)
                    .padding()
                
            }// HStack
            .frame(height: 50)
            .background(Color.theme.secndaryBackgroundColor)
            .cornerRadius(10)
            .padding(.horizontal)
            
            // request ride button
            Button {
                // Action
                homeViewModel.requestTrip()
                homeViewModel.trip?.state = .requested
            } label: {
                Text("CONFIRM RIDE")
                    .fontWeight(.bold)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 50)
                    .background(.blue)
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
            
        }// VStack1
        .padding(.bottom, 24)
        .background(Color.theme.backgroundColor)
        .cornerRadius(16)
        
        
    }
}

#Preview {
    RideRequestView()
}
