import Firebase

struct SavedLocation: Codable {
    let title: String
    let address: String
    let coordinate: GeoPoint
}
