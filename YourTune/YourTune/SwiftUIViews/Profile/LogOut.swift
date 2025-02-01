//
//  LogOut.swift
//  YourTune
//
//  Created by Beka on 31.01.25.
//

import SwiftUI

struct LogoutButtonView: View {
    let onLogout: () -> Void

    var body: some View {
        Button(action: onLogout) {
            Text("Logout")
                .padding()
                .frame(maxWidth: .infinity)
                .background(ThemeManager.shared.buttonGradient)
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(radius: 5)
        }
        .padding(.horizontal)
    }
}
