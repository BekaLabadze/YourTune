//
//  YourTuneApp.swift
//  YourTune
//
//  Created by Beka on 11.01.25.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct swiftuianduikitApp: App {
    @State var themeManager = ThemeManager.shared
    
    init() {
        FirebaseApp.configure()
        themeManager.setupTabBarAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                themeManager.backgroundGradient.ignoresSafeArea()
                LoginView()
                    .environmentObject(themeManager)
                    .onOpenURL { url in
                        GIDSignIn.sharedInstance.handle(url)
                }
            }
            .onAppear {
                setupNavigationBarAppearance()
            }
        }
    }

    func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = nil
        appearance.titleTextAttributes = [
            .foregroundColor: themeManager.uiKitTextColor,
            .font: UIFont.boldSystemFont(ofSize: 20)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: themeManager.uiKitTextColor,
            .font: UIFont.boldSystemFont(ofSize: 34)
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
