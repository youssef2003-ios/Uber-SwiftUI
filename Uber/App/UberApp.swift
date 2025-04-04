//
//  UberApp.swift
//  Uber
//
//  Created by youssef ahmed on 15/02/2025.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Firebase...")
        FirebaseApp.configure()
        
        return true
    }
}

@main
struct UberApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
//    @StateObject var locationViewModel = LocationSearchViewModel()
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var homeViewModel = HomeViewModel()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
//                .environmentObject(locationViewModel)
                .environmentObject(authViewModel)
                .environmentObject(homeViewModel)
        }
        
    }
}
