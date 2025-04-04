import SwiftUI
import Firebase
import FirebaseAuth

struct HomeView: View {
    
    @State private var mapState = MapViewState.noInput
    @State private var showSideMenu = false
    @State private var shouldUpdateMap = false
    //    @EnvironmentObject var locationViewModel: LocationSearchViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    var body: some View {
        
        Group {
            
            if authViewModel.userSession == nil {
                LoginView()
            } else if let user = authViewModel.currentUser {
                NavigationStack {
                    ZStack {
                        if showSideMenu {
                            SideMenuView(user: user)
                        }
                        
                        mapView
                            .offset(x: showSideMenu ? 316 : 0)
                            .shadow(
                                color: showSideMenu ? Color.theme.primaryTextColor : .clear,
                                radius: 10
                            )
                        
                    }// ZStack
                    .onAppear {
                        showSideMenu = false
                    }
                    // Add these alert modifiers to the end of your mapView variable in HomeView
                    .alert("Cancel Trip", isPresented: $homeViewModel.showPassengerCancellationAlert) {
                        Button("Yes, Cancel Trip", role: .destructive) {
                            homeViewModel.confirmCancelTripAsPassenger()
                        }
                        Button("No, Keep Trip", role: .cancel) {}
                    } message: {
                        Text("Are you sure you want to cancel this trip? The driver will be notified.")
                    }
                    .alert("Cancel Trip", isPresented: $homeViewModel.showDriverCancellationAlert) {
                        Button("Yes, Cancel Trip", role: .destructive) {
                            homeViewModel.confirmCancelTripAsDriver()
                        }
                        Button("No, Keep Trip", role: .cancel) {}
                    } message: {
                        Text("Are you sure you want to cancel this trip? The passenger will be notified.")
                    }
                    
                }// NavigationStack
            }
            
        }// Group
        
    }
}

extension HomeView {
    
    var mapView: some View {
        
        ZStack(alignment: .bottom) {
            
            ZStack(alignment: .top) {
                
                UberMapViewRepresentable(
                    mapState: $mapState,
                    shouldUpdateMap: $shouldUpdateMap
                )
                .ignoresSafeArea()
                
                if let user = authViewModel.currentUser{
                    if user.accountType == .passenger {
                        if mapState == .searchingForLocation {
                            LocationSearchView()
                        } else if mapState == .noInput {
                            LocationSearchActivationView()
                                .padding(.top, 72)
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        mapState = .searchingForLocation
                                    }
                                }
                        }
                    }
                }
                
                MapViewActionButton(
                    mapState: $mapState,
                    showSideMenu: $showSideMenu,
                    shouldUpdateMap: $shouldUpdateMap
                )
                .padding(.leading)
                .padding(.top, 1)
                
            }// ZStack2
            
            if let user = authViewModel.currentUser {
                homeViewModel.viewForState(mapState, user: user)
                    .transition(.move(edge: .bottom))
            }
            
        }// ZStack1
        .edgesIgnoringSafeArea(.bottom)
        // Receive value form the Publisher
        .onReceive(LocationManager.shared.$userLocation) { location in
            homeViewModel.userLocaton = location
        }
        .onReceive(homeViewModel.$selectedUberLocation) { locaion in
            if locaion != nil {
                withAnimation(.spring()) {
                    mapState = .locationSelected
                }
            }
        }
        .onReceive(homeViewModel.$trip) { trip  in
            guard let trip = trip else {
                self.mapState = .noInput
                return
            }
            
            withAnimation(.spring()) {
                switch trip.state {
                case .requested:
                    mapState = .tripRequested
                case .rejected:
                    mapState = .tripRejected
                case .accepted:
                    mapState = .tripAccepted
                case .passengerCancelled:
                    mapState = .tripCancelledByPassenger
                case .driverCancelled:
                    mapState = .tripCancelledByDriver
                }
            }
        }
        .onReceive(homeViewModel.$shouldUpdateMap) { shouldUpdate in
            if shouldUpdate {
                self.shouldUpdateMap = true
                DispatchQueue.main.async {
                    homeViewModel.shouldUpdateMap = false
                }
            }
        }
        
        
        
    }
    
}


#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}

