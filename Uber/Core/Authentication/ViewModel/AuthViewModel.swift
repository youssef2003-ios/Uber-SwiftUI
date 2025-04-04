import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class AuthViewModel: ObservableObject {
    
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var isLoading: Bool = false
    
    private let service = UserService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        userSession = Auth.auth().currentUser
        fetchUser()
    }
    
    func signIn(withEmail email: String, password: String, completion: ((Error?) -> Void)? = nil) {
        isLoading = true
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            self.isLoading = false
            
            if let error = error {
                print("DEBUG: error in signIn...\(error.localizedDescription)")
                completion?(error)
                return
            }
            
            self.userSession = result?.user
            ///Update the current user
            self.service.fetchUser()
        }
        
    }// signInUser
    
    func registerUser(withEmail email: String, password: String, fullname: String, completion: ((Error?) -> Void)? = nil) {
        guard let location = LocationManager.shared.userLocation else {return}
        
        isLoading = true
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            self.isLoading = false
            
            if let error = error {
                print("DEBUG: error in signUp...\(error.localizedDescription)")
                completion?(error)
                return
            }
            
            guard let firebaseUser = result?.user else {return}
            self.userSession = firebaseUser
            
            let user = User(uid: firebaseUser.uid,
                            fullname: fullname,
                            email: email,
                            coordinates: GeoPoint(latitude: location.latitude,
                                                  longitude: location.longitude),
                            accountType: .passenger)
            
            ///Update the current user
            self.currentUser = user
            
            guard let encodedUser = try? Firestore.Encoder().encode(user) else {return}
            Firestore.firestore().collection("users").document(firebaseUser.uid).setData(encodedUser)
        }
        
    }// registerUser
    
    func updateAccountType(to accountType: AccountType) {
        guard let currentUser = currentUser else { return }
        
        let updatedUser = User(
            uid: currentUser.uid,
            fullname: currentUser.fullname,
            email: currentUser.email,
            coordinates: currentUser.coordinates,
            accountType: accountType,
            homeLocation: currentUser.homeLocation,
            workLocation: currentUser.workLocation
        )
        
        do {
            let encodedUser = try Firestore.Encoder().encode(updatedUser)
            Firestore.firestore().collection("users")
                .document(currentUser.uid)
                .setData(encodedUser) { error in
                    if let error = error {
                        print("DEBUG: Error updating account type: \(error.localizedDescription)")
                        return
                    }
                    self.currentUser = updatedUser
                }
        } catch {
            print("DEBUG: Error encoding updated user: \(error.localizedDescription)")
        }
    }// updateAccountType
    
    func signOut(completion: ((Error?) -> Void)? = nil) {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
            self.service.user = nil
        } catch {
            print("Error signing out: \(error.localizedDescription)")
            completion?(error)
        }
    }// signOut
    
    private func fetchUser() {
        service.$user
            .sink { user in
                self.currentUser = user
            }
            .store(in: &cancellables)
    }
    
    
}// AuthViewModel
