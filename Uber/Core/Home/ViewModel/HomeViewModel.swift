import Foundation
import SwiftUICore
import Firebase
import FirebaseAuth
import Combine
import MapKit

enum LocationResultsViewConfig {
    case ride
    case saveLocation(SavedLocationViewModel)
}

class HomeViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    @Published var drivers = [User]()
    @Published var trip: Trip?
    @Published var expectedTravelTime: Double?
    @Published var shouldUpdateMap: Bool = false
    @Published var dismissSearchView: Bool = false
    @Published var showPassengerCancellationAlert: Bool = false
    @Published var showDriverCancellationAlert: Bool = false
    var currentUser: User?
    private let service = UserService.shared
    private var cancellables = Set<AnyCancellable>()
    var routeToPickupLocation: MKRoute?
    
    // Location search properties
    @Published var results = [MKLocalSearchCompletion]()
    @Published var selectedUberLocation: UberLocation?
    @Published var pickupTime: String?
    @Published var dropOffTime: String?
    var userLocaton: CLLocationCoordinate2D?
    private let searchCompleter = MKLocalSearchCompleter()
    
    var queryFregment: String = "" {
        // Update in real time(mean any changes in text field will execute or update the code in didSet{} )
        didSet {
            searchCompleter.queryFragment = queryFregment
        }
    }
    
    // MARK: - Lifecycle
    
    override init() {
        super.init()
        fetchUser()
        searchCompleter.delegate = self
        searchCompleter.queryFragment = queryFregment
    }
    
    // MARK: - Helpers
    
    var tripCancelledMessage: String {
        guard let user = currentUser, let trip = trip else { return "" }
        
        if user.accountType == .passenger {
            if trip.state == .passengerCancelled {
                return "Your trip has been cancelled"
            } else if trip.state == .driverCancelled {
                return "Your driver cancelled this trip"
            }
        } else {
            if trip.state == .passengerCancelled {
                return "The trip has been cancelled by the passenger"
            } else if trip.state == .driverCancelled {
                return "Your trip has been cancelled"
            }
        }
        
        return ""
    }
    
    func viewForState(_ state: MapViewState, user: User) -> some View {
        switch state {
        case .locationSelected, .polylineAdded:
            return AnyView(RideRequestView())
        case .tripRequested:
            if user.accountType == .passenger {
                return AnyView(TripLoadingView())
            } else {
                if let trip = trip {
                    return AnyView(AcceptTripView(trip: trip))
                }
            }
        case .tripAccepted:
            if user.accountType == .passenger {
                return AnyView(TripAcceptedView())
            } else {
                if let trip = trip {
                    return AnyView( PickupPassengerView(trip: trip))
                }
            }
        case .tripCancelledByPassenger, .tripCancelledByDriver:
            return AnyView(TripCancelledView())
            
        default:
            break
        }
        
        return AnyView(Text(""))
    }
    
    // MARK: - User API
    
    private func fetchUser() {
        service.$user
            .sink { [weak self] user in
                guard let self = self else { return }
                self.currentUser = user
                guard let user = user else { return }
                
                // Clear drivers when switching to driver account
                if user.accountType == .driver {
                    self.drivers.removeAll()
                } else if user.accountType == .passenger {
                    self.fetchDrivers()
                    self.addTripObserverForPassenger()
                }
                
                // Existing driver-specific logic
                if user.accountType == .driver {
                    self.fetchAndAddTripObserverForDriver()
                }
            }
            .store(in: &cancellables)
    }// fetchUser
    
    func updateTripState(_ state: TripState) {
        guard let trip = trip else {return}
        
        var data = ["state" : state.rawValue]
        
        if state == .accepted {
            data["travelTimeToPassenger"] = trip.travelTimeToPassenger
        }
        
        Firestore.firestore().collection("trips").document(trip.id).updateData(data) { error in
            if let error = error {
                print("DEBUGE: Error in update the trip state.. \(error.localizedDescription)")
            }
            print("DEBUG: Did update trip with state \(state)")
        }
    }// updateTripState
    
    func deleteTrip() {
        guard let trip = trip else { return }
        
        Firestore.firestore().collection("trips").document(trip.id).delete { _ in
            self.trip = nil
        }
    }
    
    func resetDismissSearchView() {
        self.dismissSearchView = false
    }
    
}// HomeViewModel

// MARK: - Passenger API

extension HomeViewModel {
    
    func addTripObserverForPassenger() {
        guard let currentUser = currentUser, currentUser.accountType == .passenger else {return}
        
        Firestore.firestore().collection("trips")
            .whereField("passengerUid", isEqualTo: currentUser.uid)
            .addSnapshotListener { snapshot, error in
                guard let change = snapshot?.documentChanges.first,
                      change.type == .added || change.type == .modified else {return}
                
                guard let trip = try? change.document.data(as: Trip.self) else {return}
                self.trip = trip
                print("DEBUG: Updated trip state is \(trip.state)")
                
            }
    }// addTripObserverForPassenger
    
    func fetchDrivers() {
        Firestore.firestore().collection("users")
            .whereField("accountType", isEqualTo: AccountType.driver.rawValue)
            .getDocuments { snapshout, _ in
                guard let documents = snapshout?.documents else {return}
                let drivers = documents.compactMap({ try? $0.data(as: User.self) })
                
                self.drivers = drivers
            }
    }// fetchDrivers
    
    func requestTrip() {
        guard let driver = drivers.first else {return}
        guard let currentUser = currentUser else {return}
        guard let dropoffLocation = selectedUberLocation else {return}
        let dropoffGeoPoint = GeoPoint(latitude: dropoffLocation.coordinate.latitude,
                                       longitude: dropoffLocation.coordinate.longitude)
        let userLocation = CLLocation(latitude: currentUser.coordinates.latitude,
                                      longitude: currentUser.coordinates.longitude)
        
        let tripCost = self.computeRidePrice(forType: .uberX)
        
        getPlacemark(forLocation: userLocation) { placemark, _ in
            guard let placemark = placemark else {return}
            
            let trip = Trip(
                passengerUid: currentUser.uid,
                driverUid: driver.uid,
                passengerName: currentUser.fullname,
                driverName: driver.fullname,
                passengerLocation: currentUser.coordinates,
                driverLocation: driver.coordinates,
                pickupLocationName: placemark.name ?? "Current Location",
                dropoffLocationName: dropoffLocation.title,
                pickupLocationAddress: self.addressFromPlacemark(placemark),
                dropoffLocationAddress: dropoffLocation.address,
                pickupLocation: currentUser.coordinates,
                dropoffLocation: dropoffGeoPoint,
                tripCost: tripCost,
                travelTimeToPassenger: 0,
                distanceToPassenger: 0.0,
                state: .requested
            )
            
            guard let encodedTrip = try? Firestore.Encoder().encode(trip) else {return}
            
            Firestore.firestore().collection("trips").document().setData(encodedTrip) { _ in
                print("DEBUG: Did upload trip to firestore")
            }
        }
        
    }// requestTrip
    
    func cancelTripAsPassenger() {
        showPassengerCancellationAlert = true
    }
    
    func confirmCancelTripAsPassenger() {
        showPassengerCancellationAlert = false
        updateTripState(.passengerCancelled)
    }
    
}// extension

// MARK: - Driver API

extension HomeViewModel {
    
    func fetchAndAddTripObserverForDriver() {
        guard let currentUser = currentUser, currentUser.accountType == .driver else {return}
        
        Firestore.firestore().collection("trips")
            .whereField("driverUid", isEqualTo: currentUser.uid)
            .addSnapshotListener { snapshot, error in
                guard let change = snapshot?.documentChanges.first,
                      change.type == .added || change.type == .modified else {return}
                
                guard let trip = try? change.document.data(as: Trip.self) else {return}
                
                self.trip = trip
                
                self.getDestinationRoute(from: trip.driverLocation.toCoordinate(),
                                         to: trip.pickupLocation.toCoordinate()) { route in
                    
                    self.routeToPickupLocation = route
                    self.trip?.travelTimeToPassenger = Int(route.expectedTravelTime / 60)
                    self.trip?.distanceToPassenger = route.distance
                }
                
            }
        
    }// addTripObserverForDriver
    
    func rejectTrip() {
        updateTripState(.rejected)
    }// rejectTrip
    
    func acceptTrip() {
        updateTripState(.accepted)
    }// acceptTrip
    
    func cancelTripAsDriver() {
        showDriverCancellationAlert = true
    }
    
    func confirmCancelTripAsDriver() {
        showDriverCancellationAlert = false
        updateTripState(.driverCancelled)
    }
    
}// extension

// MARK: - Location Search Helpers

extension HomeViewModel {
    
    func addressFromPlacemark(_ placemark: CLPlacemark) -> String {
        var result = ""
        
        if let thoroughfare = placemark.thoroughfare {
            result += thoroughfare
        }
        
        if let subThoroughfare = placemark.subThoroughfare {
            result += " \(subThoroughfare)"
        }
        
        if let subAdministrativeArea = placemark.subAdministrativeArea {
            result += ", \(subAdministrativeArea)"
        }
        
        return result
    }
    
    func getPlacemark(forLocation location: CLLocation, completion: @escaping(CLPlacemark?, Error?) -> Void) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("DEBUG: error with get placemarck \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let placemark = placemarks?.first else {return}
            completion(placemark, nil)
        }
    }// getPlacemarck
    
    func selectLocation(_ localSearch: MKLocalSearchCompletion, config: LocationResultsViewConfig) {
        locationSearch(forLocalSearchCompletion: localSearch) { response, error in
            if let error = error {
                print ("DEBUG: Location search failed with error\(error.localizedDescription)")
                return
            }
            
            guard let item = response?.mapItems.first else {return}
            let coordinate = item.placemark.coordinate
            
            switch config {
            case .ride:
                self.selectedUberLocation = UberLocation(title: localSearch.title, address: localSearch.subtitle, coordinate: coordinate)
                print ("DEBUG: Location Coordinate \(coordinate)")
                
            case .saveLocation(let viewModel):
                guard let uid = Auth.auth().currentUser?.uid else {return}
                
                let savedLocation = SavedLocation(title: localSearch.title,
                                                  address: localSearch.subtitle,
                                                  coordinate: GeoPoint(latitude: coordinate.latitude,
                                                                       longitude: coordinate.longitude))
                
                guard let encodedLocation = try? Firestore.Encoder().encode(savedLocation) else {return}
                
                Firestore.firestore().collection("users").document(uid).updateData([
                    viewModel.databaseKey : encodedLocation
                ])
                
                print("DEBUG: Save Location here..")
                
                DispatchQueue.main.async {
                    self.dismissSearchView = true
                }
            }
            
        }// locationSearch
        
    }// selectLocation
    
    func locationSearch(forLocalSearchCompletion localSearch: MKLocalSearchCompletion, completion: @escaping MKLocalSearch.CompletionHandler ) {
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = localSearch.title.appending(localSearch.subtitle)
        
        let search = MKLocalSearch(request: searchRequest)
        
        search.start(completionHandler: completion)
    }
    
    func computeRidePrice(forType type: RideType) -> Double {
        guard let userCoordinate = userLocaton else { return 0.0 }
        guard let destCoordinate = selectedUberLocation?.coordinate else { return 0.0 }
        
        let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        let destLocation = CLLocation(latitude: destCoordinate.latitude, longitude: destCoordinate.longitude)
        
        
        let tripDistanceInMeters = userLocation.distance(from: destLocation)
        
        return type.computePrice(for: tripDistanceInMeters)
    }
    
    func getDestinationRoute(from userLocationCoordinate: CLLocationCoordinate2D, to destinationCoordinate: CLLocationCoordinate2D, completion: @escaping (MKRoute) -> Void) {
        
        let userPlaceMark = MKPlacemark(coordinate: userLocationCoordinate)
        let destPlaceMark = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: userPlaceMark)
        request.destination = MKMapItem(placemark: destPlaceMark)
        
        let directions = MKDirections(request: request)
        
        directions.calculate { response, error in
            if let error = error {
                print("DEBUG: Failed to get directions with error \(error.localizedDescription)")
                return
            }
            
            guard let route = response?.routes.first else {return}
            self.configurePickupAndDropoffTimes(with: route.expectedTravelTime)
            
            completion(route)
        }
        
    }
    
    func configurePickupAndDropoffTimes(with expectedTravelTime: Double) {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        
        pickupTime = formatter.string(from: Date())
        dropOffTime = formatter.string(from: Date() + expectedTravelTime)
    }
    
}

// MARK: - MKLocalSearchCompleterDelegate

extension HomeViewModel: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results
    }
    
}
