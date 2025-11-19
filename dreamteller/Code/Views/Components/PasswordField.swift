//
//  PasswordField.swift
//  dreamteller
//
//  Created by suha.isik on 28.10.2025.
//

import SwiftUI

struct PasswordField: View {
    @Binding var text: String
    var placeholder: String
    @Binding var showPassword: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 30/255, green: 41/255, blue: 50/255))
                .frame(height: 56)
            
            HStack {
                if showPassword {
                    TextField(placeholder, text: $text)
                        .autocapitalization(.none)
                        .foregroundColor(.white)
                } else {
                    SecureField(placeholder, text: $text)
                }
                
                Button(action: {
                    showPassword.toggle()
                }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(Color(red: 150/255, green: 161/255, blue: 175/255))
                }
            }
            .padding(.horizontal, 16)
            .foregroundColor(.white)
        }
    }
}
#Preview {
    PasswordField(text: .constant(""), placeholder: "add your password", showPassword: .constant(false))
}
