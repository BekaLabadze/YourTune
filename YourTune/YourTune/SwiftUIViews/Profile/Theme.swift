//
//  Theme.swift
//  YourTune
//
//  Created by Beka on 31.01.25.
//

import SwiftUI

struct ThemeToggleView: View {
    @Binding var isDarkModeToggle: Bool
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack {
            HStack {
                Text(isDarkModeToggle ? "Switch to Light Mode" : "Switch to Dark Mode")
                    .foregroundColor(themeManager.textColor)
                    .font(.headline)
                Spacer()
                Toggle("", isOn: $isDarkModeToggle)
                    .toggleStyle(SwitchToggleStyle(tint: themeManager.isDarkMode ? .green : .gray))
                    .onChange(of: isDarkModeToggle) { newValue in
                        themeManager.isDarkMode = newValue
                    }
                    .frame(width: 55)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(themeManager.isDarkMode ? Color.black.opacity(0.2) : Color.white.opacity(0.2))
            )
            .padding(.horizontal)
        }
    }
}
