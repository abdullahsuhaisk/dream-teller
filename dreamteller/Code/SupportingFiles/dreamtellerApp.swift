//
//  dreamtellerApp.swift
//  dreamteller
//
//  Created by suha.isik on 28.10.2025.
//

import SwiftUI
import SwiftData
import Firebase
//import FirebaseAppCheck

@main
struct dreamtellerApp: App {
    init() {
        // Global navigation bar title color + background
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color(red: 10/255, green: 25/255, blue: 47/255))
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .systemTeal // bar button items
        
        // Transparent tab bar so gradient/background from content shows through
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithTransparentBackground()
        tabAppearance.backgroundEffect = nil
        tabAppearance.backgroundColor = .clear
        // Item colors
        tabAppearance.stackedLayoutAppearance.selected.iconColor = .white
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
        tabAppearance.stackedLayoutAppearance.normal.iconColor = .lightGray
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.lightGray]
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        
        #if DEBUG
        // let providerFactory = AppCheckDebugProviderFactory()
        // AppCheck.setAppCheckProviderFactory(providerFactory)
        #endif
        
        FirebaseApp.configure()
    }
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var dreamVM = DreamViewModel()
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authVM.isAuthenticated {
                    MainTabView()
                } else if hasSeenOnboarding {
                    LoginView()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(authVM)
            .environmentObject(dreamVM)
            .task(id: authVM.isAuthenticated) {
                // When auth state flips to true fetch token and preload data
                if authVM.isAuthenticated {
                    await authVM.fetchIDToken()
                    dreamVM.setAuthToken(authVM.idToken)
                    await dreamVM.loadDreamsForSelectedDate()
                    await dreamVM.loadMonthlyEntries(year: dreamVM.selectedDate.y(),
                                                     month: dreamVM.selectedDate.m())
                } else {
                    dreamVM.setAuthToken(nil)
                }
            }
        }
    }
}
