//
//  YourTuneApp.swift
//  YourTune
//
//  Created by Beka on 11.01.25.
//

import SwiftUI
import Firebase

@main
struct YourTuneApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
            WindowGroup {
                ZStack {
                LinearGradient.shinyDarkGradient.ignoresSafeArea()
                LoginView()
            }
        }
    }
}

