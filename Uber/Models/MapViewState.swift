
import Foundation

enum MapViewState {
    case noInput
    case searchingForLocation
    case locationSelected
    case polylineAdded
    case tripRequested
    case tripAccepted
    case tripRejected
    case tripCancelledByPassenger
    case tripCancelledByDriver
}
