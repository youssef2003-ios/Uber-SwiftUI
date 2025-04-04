import SwiftUI

struct MapViewActionButton: View {
    
    @Binding var mapState: MapViewState
    @Binding var showSideMenu: Bool
    @Binding var shouldUpdateMap: Bool
    //@EnvironmentObject var locationViewModel: LocationSearchViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        
        Button {
            // Action
            withAnimation(.spring()) {
                actionForState(mapState)
            }
        } label: {
            Image(systemName: imageNameForState(mapState))
                .font(.title2)
                .foregroundColor(Color.black)
                .padding()
                .background(.white)
                .clipShape(Circle())
                .shadow(color: .black, radius: 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }// body
    
    func actionForState(_ state: MapViewState) {
        switch state {
        case .noInput:
            showSideMenu.toggle()
        case .searchingForLocation:
            mapState = .noInput
        case .locationSelected,
                .polylineAdded,
                .tripAccepted,
                .tripRejected,
                .tripRequested,
                .tripCancelledByPassenger,
                .tripCancelledByDriver:
            mapState = .noInput
            homeViewModel.selectedUberLocation = nil
            // Only trigger map update when clearing route
            shouldUpdateMap = true
        }
    }
    
    func imageNameForState(_ state: MapViewState) -> String {
        switch state {
        case .noInput:
            return "line.3.horizontal"
        case .searchingForLocation,
                .locationSelected,
                .polylineAdded,
                .tripAccepted,
                .tripRejected,
                .tripRequested,
                .tripCancelledByPassenger,
                .tripCancelledByDriver:
            return "arrow.left"
        }
    }
    
}// MapViewActionButton

#Preview {
    MapViewActionButton(mapState: .constant(.searchingForLocation), showSideMenu: .constant(false), shouldUpdateMap: .constant(false))
}

