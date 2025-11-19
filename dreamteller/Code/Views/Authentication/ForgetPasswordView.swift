//
//  ForgetPassword.swift
//  dreamteller
//
//  Created by suha.isik on 31.10.2025.
//

import SwiftUI

struct ForgetPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                Spacer()
                Text("Forget Password")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 20)
            VStack(spacing: 16) {
                Text("Please enter your email address. We will send you a password reset link if it is in our user records.")
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                InputField(text: $authViewModel.email, placeholder: "Email", keyboard: .emailAddress)
                Button(action: {
                    Task {
                        await authViewModel.sendPasswordReset()
                    }
                }) {
                    Text("Send Reset Link")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
            }.padding(.horizontal)
            Spacer()
        }.background(LinearGradient.onboardingBackground.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ForgetPasswordView()
}
