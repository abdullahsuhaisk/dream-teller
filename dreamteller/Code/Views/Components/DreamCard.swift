//
//  DreamCard.swift
//  dreamteller
//
//  Created by suha.isik on 31.10.2025.
//
// DreamCard.swift
import SwiftUI

struct DreamCard: View {
    let dream: Dream
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(dream.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 180)
                .clipped()
                .cornerRadius(16)
            
            LinearGradient(
                colors: [.black.opacity(0.65), .clear],
                startPoint: .bottom,
                endPoint: .top
            )
            .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(dream.title)
                    .font(.headline.bold())
                    .foregroundColor(.white)
                Text(dream.dateKey) // show date key string
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                Text(dream.input.prefix(50) + (dream.input.count > 50 ? "…" : ""))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.85))
                if let interp = dream.interpretation {
                    Text(interp)
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .padding(.horizontal)
    }
}

#Preview {
    // Preview adapted to new Dream initializer
    let sample = Dream(id: <#String#>, dateKey: "20251118",
                       input: "I was walking through a misty forest hearing distant whispers.",
                       interpretation: "Seeking guidance / introspection",
                       title: "Walking in the woods",
                       imageName: "dream1")
    DreamCard(dream: sample)
}
