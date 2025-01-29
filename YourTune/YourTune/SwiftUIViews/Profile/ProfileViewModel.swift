//
//  ProfileViewModel.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

final class ProfileViewModel: ObservableObject {
    
    private let db = Firestore.firestore()
    @Published var errorMessage: String?
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            SessionProvider.shared.setUser(nil)
        } catch {
            errorMessage = "Error signing out: \(error.localizedDescription)"
        }
    }
}
