//
//  ToastView.swift
//  YourTune
//
//  Created by Beka on 12.01.25.
//

import SwiftUI

struct ToastView: View {
    let message: String
    var backgroundColor: Color
    
    var body: some View {
        Text(message)
            .padding()
            .foregroundColor(.white)
            .background(backgroundColor)
            .cornerRadius(10)
            .shadow(radius: 5)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.top, 50)
        
    }
}
