import SwiftUI

struct TripLoadingView: View {
    
    var body: some View {
        
        VStack {
            Capsule()
                .foregroundColor(Color(.systemGray4))
                .frame(width: 48, height: 6)
                .padding(.top, 8)
            
            HStack {
                Text("Connecting you to a driver..")
                    .font(.headline)
                    .padding()
                
                Spacer()
                
                Spinner(lineWidth: 6, height: 62, width: 62)
                    .padding()
            }// HStack
            .padding(.bottom, 24)
            
        }// VStack1
        .background(Color.theme.backgroundColor)
        .cornerRadius(16)
        .shadow(color: Color.theme.secndaryBackgroundColor, radius: 20)
        
    }
}

#Preview {
    TripLoadingView()
}
