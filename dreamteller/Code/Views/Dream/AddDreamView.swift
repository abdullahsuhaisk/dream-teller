//
//  AddDreamView.swift
//  dreamteller
//
//  Created by suha.isik on 31.10.2025.
//

import SwiftUI

struct AddDreamView: View {
    @Environment(\.dismiss) var dismiss // X butonuna basınca ekranı kapatmak için
    @State private var dreamText: String = ""
    @State private var isSaving = false

    var body: some View {
        VStack(spacing: 20) {
            // Üst başlık ve kapama butonu
            HStack {
                Spacer()
                Text("New Dream")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .font(.system(size: 18, weight: .bold))
                }
            }
            .padding(.top, 12)
            .padding(.horizontal)

            // Yazı alanı
            ZStack(alignment: .topLeading) {
                TextEditor(text: $dreamText)
                    .scrollContentBackground(.hidden) // hide default background (iOS16+)
                    .padding(.horizontal, 8)
                    .padding(.top, 12)
                    .frame(height: 300)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.12, green: 0.15, blue: 0.20))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.15, green: 0.18, blue: 0.22), lineWidth: 1)
                    )
                    .foregroundColor(.white)
                if dreamText.isEmpty {
                    Text("Write your dream")
                        .foregroundColor(.gray)
                        .padding(.top, 16)
                        .padding(.leading, 16)
                }
            }

            Spacer()

            // Alt butonlar
            HStack {
                Button(action: speakDream) {
                    Text("Speak")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 24)
                        .background(Color(red: 0.12, green: 0.15, blue: 0.20))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Spacer()

                Button(action: saveDream) {
                    if isSaving {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Save & Interpret")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 24)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(LinearGradient.onboardingBackground.ignoresSafeArea())
    }

    // MARK: - Actions
    private func speakDream() {
        print("🎙 Start voice input (not implemented yet)")
    }

    private func saveDream() {
        guard !dreamText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isSaving = true

        // Simulate saving delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("💾 Dream saved:", dreamText)
            isSaving = false
            dismiss() // ekrandan çık
        }
    }
}
#Preview {
    AddDreamView()
}


/*.sheet(isPresented: $showNewDream) {
 NewDreamView()
 }
 */

// .background(LinearGradient.onboardingBackground.ignoresSafeArea())
