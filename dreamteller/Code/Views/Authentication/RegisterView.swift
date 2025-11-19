//
//  RegisterView.swift
//  dreamteller
//
//  Created by suha.isik on 31.10.2025.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var vm: AuthViewModel
    
    @State private var showPassword = false
    @State private var showRepeatPassword = false
    
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                Spacer()
                Text("Sign Up")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                Spacer()
                // placeholder for layout balance
                Image(systemName: "chevron.left")
                    .opacity(0)
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            Spacer()
            
            // 🧾 Input fields
            VStack(spacing: 16) {
                InputField(text: $vm.name, placeholder: "Name")
                InputField(text: $vm.email, placeholder: "Email")
                PasswordField(text: $vm.password, placeholder: "Password", showPassword: $showPassword)
                PasswordField(text: $vm.repeatPassword, placeholder: "Repeat Password", showPassword: $showRepeatPassword)
            }
            .padding(.horizontal)
            
            if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            
            // 🟦 Sign Up button
            Button(action: {
                Task {
                    await vm.signUp()
                }
                print("Sign Up tapped")
            }) {
                if vm.isLoading {
                    ProgressView() // loading spinner
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.7))
                        .cornerRadius(12)
                } else {
                    Text("Sign Up")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            
        }.background(LinearGradient.onboardingBackground.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    RegisterView().environmentObject(AuthViewModel())
}
