//
//  DreamExtension.swift
//  dreamteller
//
//  Created by suha.isik on 19.11.2025.
//

import Foundation

extension Dream {
    // Simple placeholder logic; adjust mapping as needed
    var imageName: String {
        if interpretation == nil { return "nodream" }
        return "dream1" // Or choose based on content
    }
    
    var titleOrFallback: String {
        title ?? "Dream"
    }
}
