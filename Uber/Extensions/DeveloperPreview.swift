import SwiftUI
import Firebase

extension PreviewProvider {
    static var dev: DeveloperPreview {
        return DeveloperPreview.shared
    }
}


class DeveloperPreview {
    static let shared = DeveloperPreview()
    let mockUser = User(uid: UUID().uuidString,
                       fullname: "Youssef Zahran",
                       email: "test1@gmail.com",
                       coordinates: GeoPoint(latitude: 37.41, longitude: -122.05),
                       accountType: .passenger,
                       homeLocation: nil,
                       workLocation: nil)
}
