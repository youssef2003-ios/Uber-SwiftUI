import Foundation
import Firebase
import FirebaseAuth

class UserService: ObservableObject {
    
    static let shared = UserService()
    
    @Published var user: User?
    
    init(){
        print("DEBUG: Did init user service")
        fetchUser()
        // Listen for refresh notifications
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUserData),
                                               name: NSNotification.Name("RefreshUserData"), object: nil)
    }
    
    @objc func refreshUserData() {
        fetchUser()
    }
    
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            print("DEBUG: Did fetch user from firestore")
            
            if let error = error {
                print("DEBUG: Error fetch user for UserService... \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot, snapshot.exists else {return}
            guard let user = try? snapshot.data(as: User.self) else {return}
            self.user = user
        }
    }
    
}// UserService

