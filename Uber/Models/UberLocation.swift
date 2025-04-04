import Foundation
import CoreLocation

struct UberLocation: Identifiable {
    let id = UUID().uuidString
    let title: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    
}
