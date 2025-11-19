//
//  HomeView.swift
//  dreamteller
//
//  Created by suha.isik on 31.10.2025.
//

import SwiftUI

import SwiftUI

struct MainTabView: View {
    var body: some View {
        ZStack {
            // Unified gradient background
            LinearGradient.onboardingBackground.ignoresSafeArea()
            TabView {
                HomeView()
                    .tabItem {
                        Image(systemName: "book")
                        Text("Journal")
                    }

                AddDreamView()
                    .tabItem {
                        Image(systemName: "plus")
                        Text("Add")
                    }

                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape")
                        Text("Settings")
                    }
            }
            // Ensure tab bar is transparent in SwiftUI layer (iOS 16+)
            .toolbarBackground(.clear, for: .tabBar)
            .toolbarBackground(.hidden, for: .tabBar)
        }
    }
}

#Preview {
    MainTabView()
}
