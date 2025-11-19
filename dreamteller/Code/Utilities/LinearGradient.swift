//
//  LinearGradient.swift
//  dreamteller
//
//  Created by suha.isik on 28.10.2025.
//

import SwiftUI

extension LinearGradient {
    static let onboardingBackground = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 10/255, green: 25/255, blue: 47/255),   // top: deep blue
            Color(red: 3/255, green: 10/255, blue: 20/255)     // bottom: near black
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
}
