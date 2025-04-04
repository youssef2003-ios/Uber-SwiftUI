import Foundation
import SwiftUI
import MapKit
import FirebaseFirestore
import FirebaseAuth

class LocationSearchViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
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
    
    // MARK: Lifecycle
    
    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.queryFragment = queryFregment
    }
    
    // MARK: - Helpers
    
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
                self.selectedUberLocation = UberLocation(title: localSearch.title,
                                                         address: localSearch.subtitle,
                                                         coordinate: coordinate)
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
    
    
}// LocationSearchViewModel


// MARK: - MKLocalSearchCompleterDelegate

extension LocationSearchViewModel: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results
    }
    
}
