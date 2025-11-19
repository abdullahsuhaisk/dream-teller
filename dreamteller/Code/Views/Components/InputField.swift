//
//  InputField.swift
//  dreamteller
//
//  Created by suha.isik on 28.10.2025.
//

import SwiftUI

struct InputField: View {
    @Binding var text: String
    var placeholder: String
    var keyboard: UIKeyboardType = .default
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 30/255, green: 41/255, blue: 50/255))
                .frame(height: 56)
            
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color(red: 145/255, green: 160/255, blue: 176/255))
                    .padding(.leading, 16)
            }
            
            TextField("", text: $text)
                .keyboardType(keyboard)
                .autocapitalization(.none)
                .padding(.leading, 16)
                .foregroundColor(.white)
                .frame(height: 56)
        }
    }
}


#Preview {
    InputField(text: .constant(""), placeholder: "Enter text")
}
