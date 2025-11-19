//
//  SettingsView.swift
//  dreamteller
//
//  Created by suha.isik on 31.10.2025.
//

//
//  HomeView.swift
//  dreamteller
//
//  Created by suha.isik on 31.10.2025.
//

import SwiftUI

struct SettingsView: View {
    @State private var dailyReminder = false
    @State private var newInterpretations = false
    @State private var selectedLanguage = "English"
    private let languages = ["English", "Spanish", "French"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.onboardingBackground
                    .ignoresSafeArea()
                VStack(alignment: .leading, spacing: 32) {
                    
                    // Notifications Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Notifications")
                            .font(.title3).bold().foregroundColor(.white)
                        
                        Toggle(isOn: $dailyReminder) {
                            VStack(alignment: .leading) {
                                Text("Daily Dream Journal Reminder").bold()
                                    .foregroundColor(.white)
                                Text(
                                    "Receive daily reminders to record your dreams"
                                )
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            }
                        }
                        
                        Toggle(isOn: $newInterpretations) {
                            VStack(alignment: .leading) {
                                Text("New Interpretations").bold()
                                    .foregroundColor(.white)
                                Text(
                                    "Get notified when new dream interpretations are available"
                                )
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    // Language Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Language")
                            .font(.title3).bold().foregroundColor(.white)
                        
                        HStack(spacing: 0) {
                            ForEach(languages, id: \.self) { language in
                                Button(action: {
                                    selectedLanguage = language
                                }) {
                                    Text(language)
                                        .font(
                                            .system(size: 16, weight: .semibold)
                                        )
                                        .foregroundColor(
                                            selectedLanguage == language
                                            ? .white : .gray
                                        )
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(
                                            ZStack {
                                                if selectedLanguage == language
                                                {
                                                    RoundedRectangle(
                                                        cornerRadius: 25
                                                    )
                                                    .fill(Color.black)
                                                    .matchedGeometryEffect(
                                                        id: "selection",
                                                        in: animationNamespace)
                                                }
                                            }
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }.background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color(red: 0.12, green: 0.15, blue: 0.20))
                        )
                    }
                    
                    // Feedback Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Feedback")
                            .font(.title3).bold()
                            .foregroundColor(.white)
                        
                        Button(action: {}) {
                            HStack {
                                Text("Feedback")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding()
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .padding()
                                
                            }.cornerRadius(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(
                                            Color(
                                                red: 0.12, green: 0.15,
                                                blue: 0.20))
                                )
                        }
                    }
                    
                    Spacer()
                    
                    // Logout Button
                    Button(action: {
                        print("Logout tapped")
                    }) {
                        Text("Logout")
                            .bold()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        Color(
                                            red: 0.12, green: 0.15, blue: 0.20))
                            )
                            .cornerRadius(16)
                    }
                }
                .padding()
                .navigationTitle("Settings")
            }
        }
    }
    // Matched geometry effect for smooth animation
    @Namespace private var animationNamespace
}

#Preview {
    SettingsView()
}
