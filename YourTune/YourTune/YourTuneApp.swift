//
//  YourTuneApp.swift
//  YourTune
//
//  Created by Beka on 11.01.25.
//

import SwiftUI
import Firebase

@main
struct swiftuianduikitApp: App {
    @StateObject var userViewModel = UserViewModel()
    @StateObject var themeManager = ThemeManager.shared
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                themeManager.backgroundGradient.ignoresSafeArea()
                LoginView()
                    .environmentObject(userViewModel)
                    .environmentObject(themeManager)
            }
        }
    }
    
    func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = nil
        appearance.backgroundColor = themeManager.isDarkMode ? UIColor.black : UIColor.white
        appearance.titleTextAttributes = [
            .foregroundColor: themeManager.isDarkMode ? UIColor.white : UIColor.black,
            .font: UIFont.boldSystemFont(ofSize: 20)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: themeManager.isDarkMode ? UIColor.white : UIColor.black,
            .font: UIFont.boldSystemFont(ofSize: 34)
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
