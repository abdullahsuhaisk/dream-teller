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
import Foundation // Use Foundation instead of Logger

@main
struct dreamtellerApp: App {
    init() {
        Logger.log("App initialization started", level: .info)
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
        Logger.log("Navigation bar appearance configured", level: .debug)
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
        Logger.log("Tab bar appearance configured", level: .debug)
        #if DEBUG
        // let providerFactory = AppCheckDebugProviderFactory()
        // AppCheck.setAppCheckProviderFactory(providerFactory)
        Logger.log("AppCheck debug provider factory would be set in DEBUG mode", level: .debug)
        #endif
        FirebaseApp.configure()
        Logger.log("Firebase configured", level: .info)
    }
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var dreamVM = DreamViewModel()
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authVM.isAuthenticated {
                    MainTabView()
                        .onAppear {
                            // Logger.log("User is authenticated, showing MainTabView", level: .info)
                        }
                } else if hasSeenOnboarding {
                    LoginView()
                        .onAppear {
                            // Logger.log("User has seen onboarding, showing LoginView", level: .info)
                        }
                } else {
                    OnboardingView()
                        .onAppear {
                            // Logger.log("User has not seen onboarding, showing OnboardingView", level: .info)
                        }
                }
            }
            .environmentObject(authVM)
            .environmentObject(dreamVM)
            .task(id: authVM.isAuthenticated) {
                if authVM.isAuthenticated {
                    // Logger.log("Auth state changed to authenticated, fetching ID token and loading dreams", level: .info)
                    await authVM.fetchIDToken()
                    dreamVM.setAuthToken(authVM.idToken)
                    await dreamVM.loadDreamsForSelectedDate()
                    await dreamVM.loadMonthlyEntries(year: dreamVM.selectedDate.y(),
                                                     month: dreamVM.selectedDate.m())
                    // Logger.log("Dreams and monthly entries loaded for authenticated user", level: .info)
                } else {
                    // Logger.log("Auth state changed to unauthenticated, clearing dreamVM auth token", level: .info)
                    dreamVM.setAuthToken(nil)
                }
            }
        }
    }
}
