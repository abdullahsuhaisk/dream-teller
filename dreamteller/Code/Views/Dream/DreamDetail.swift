//
//  DreamDetail.swift
//  dreamteller
//
//  Created by suha.isik on 5.11.2025.
//
import SwiftUI
import UIKit // Needed for UIActivityViewController

struct DreamDetailView: View {
    let dream: Dream
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // MARK: - Image & Date
                ZStack(alignment: .bottomLeading) {
                    Image(dream.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(16)
                    
                    Text(formattedDate(from: dream.dateKey))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                        .padding()
                }
                
                // MARK: - Dream Text & Interpretation
                VStack(alignment: .leading, spacing: 12) {
                    Text(dream.input)
                        .foregroundColor(.white.opacity(0.9))
                        .font(.body)
                        .multilineTextAlignment(.leading)
                    
                    Divider().background(Color.white.opacity(0.2))
                    
                    Text("Interpretation")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(dream.interpretation ?? "No interpretation available.")
                        .foregroundColor(.white.opacity(0.9))
                        .font(.body)
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal)
                
                // MARK: - Share Button
                Button(action: shareDream) {
                    Text("Share")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
        .background(LinearGradient.onboardingBackground.ignoresSafeArea())
        .navigationTitle(dream.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formattedDate(from key: String) -> String {
        // key expected yyyyMMdd
        let f = DateFormatter()
        f.calendar = .init(identifier: .gregorian)
        f.locale = .init(identifier: "en_US_POSIX")
        f.dateFormat = "yyyyMMdd"
        if let date = f.date(from: key) {
            let out = DateFormatter()
            out.dateFormat = "dd.MM.yyyy"
            return out.string(from: date)
        }
        return key
    }
    
    private func shareDream() {
        let textToShare = "\(dream.title)\n\n\(dream.input)" + (dream.interpretation != nil ? "\n\nInterpretation:\n\(dream.interpretation!)" : "")
        let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

#Preview {
    let mock = Dream(
        dateKey: "20251118",
        input: "I was flying over a luminescent forest while a whale guided me. The sky was filled with vibrant colors. I felt a sense of peace and joy. I saw a path that led me to a beautiful beach.",
        interpretation: "Symbolizes guidance, freedom, and emerging intuition. Represents a journey towards self-discovery and emotional depth.",
        title: "Forest Flight",
        imageName: "dream1"
    )
    NavigationStack {
        DreamDetailView(dream: mock)
    }
}
