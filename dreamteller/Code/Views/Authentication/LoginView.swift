//
//  Login.swift
//  dreamteller
//
//  Created by suha.isik on 28.10.2025.
//

import SwiftUI

struct LoginView: View {
    // MARK: - State
    @EnvironmentObject var vm: AuthViewModel
    
    @State private var isShowingMainApp = false
    @State private var isShowingRegister = false
    @State private var isShowingForgotPassword = false
    @State private var showPassword: Bool = false
    
    init() {
        // Logger.log("LoginView initialized", level: .info)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.onboardingBackground
                    .ignoresSafeArea()
                
                // 2️⃣ Kaydırılabilir içerik
                ScrollView {
                    VStack(spacing: 24) {
                        // Logo ve başlık
                        VStack(spacing: 12) {
                            Image("login") // Assets’e koyduğun logo adı
                                .resizable()
                                .scaledToFit()
                                .frame(width: 260, height: 260)
                                .padding(.top, 60)
                            
                            Text("DreamTeller")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Text("Welcome")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.top, 8)
                        
                        // Giriş alanları
                        VStack(spacing: 16) {
                            InputField(text: $vm.email, placeholder: "Email", keyboard: .emailAddress)
                            PasswordField(text: $vm.password, placeholder: "Password", showPassword: $showPassword)
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 8)
                        
                        // Forgot Password link
                        HStack {
                            Spacer()
                            Button(action: {
                                // Logger.log("Forgot password button tapped", level: .info)
                                isShowingForgotPassword = true
                                print("Forgot password tapped")
                            }) {
                                Text("Forgot Password?")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(red: 120/255, green: 160/255, blue: 255/255))
                            }
                            .padding(.trailing, 24)
                            .navigationDestination(isPresented: $isShowingForgotPassword) {
                                ForgetPasswordView()
                            }
                        }
                        
                        // Login butonu
                        Button(action: {
                            // Logger.log("Login button tapped", level: .info)
                            login()
                        }) {
                            if vm.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                            } else {
                                Text("Login")
                                    .font(.system(size: 18, weight: .bold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                            }
                        }
                        .background(Color(red: 77/255, green: 148/255, blue: 255/255))
                        .cornerRadius(14)
                        .foregroundColor(.black)
                        .padding(.horizontal, 18)
                        .disabled(vm.isLoading)
                        
                        if let error = vm.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 18)
                        }
                        
                        // 👇 The navigation link to Sign Up
                        Button(action: {
                            // Logger.log("Sign up navigation button tapped", level: .info)
                            isShowingRegister = true
                        }) {
                            Text("Don’t have an account? Sign Up")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.subheadline)
                        }
                        .padding(.bottom, 30)
                        .navigationDestination(isPresented: $isShowingRegister) {
                            RegisterView()
                        }
                        
                        .padding(.bottom, 40)
                    }
                }
                
            }
        }
        .onAppear {
            // Logger.log("LoginView appeared", level: .info)
        }
    }
    
    // MARK: - Actions
    private func login() {
        // Logger.log("Login action started for email: \(vm.email)", level: .info)
        print("Login tapped")
        
        Task {
            print("Attempting to log in with email: \(vm.email)")
            await vm.signIn()
            // Logger.log("Login action completed, authenticated: \(vm.isAuthenticated)", level: .info)
            print($vm.isAuthenticated)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
