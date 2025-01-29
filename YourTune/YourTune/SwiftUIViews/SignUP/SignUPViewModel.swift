//
//  SignUPViewModel.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

final class SignUpViewModel: ObservableObject {
    @Published var user: User?
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    @Published var isAuthenticated = false
    
    func signUp(email: String, password: String, username: String) {
        guard validateEmail(email), validatePassword(password), validateUsername(username) else { return }
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            guard let userId = authResult?.user.uid else { return }
            let userData: [String: Any] = ["email": email, "username": username, "createdAt": Timestamp()]
            self?.db.collection("users").document(userId).setData(userData) { error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.isAuthenticated = true
                    self?.fetchUser()
                }
            }
        }
    }
    
    private func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if emailPredicate.evaluate(with: email) {
            return true
        } else {
            errorMessage = "Invalid email address."
            return false
        }
    }
    
    private func validatePassword(_ password: String) -> Bool {
        if password.count >= 6 {
            return true
        } else {
            errorMessage = "Password must be at least 6 characters long."
            return false
        }
    }
    
    private func validateUsername(_ username: String) -> Bool {
        if !username.isEmpty && username.count >= 3 {
            return true
        } else {
            errorMessage = "Username must be at least 3 characters long."
            return false
        }
    }
    
    func fetchUser() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            if let data = document?.data(),
               let email = data["email"] as? String,
               let username = data["username"] as? String {
                self?.user = User(id: userId, email: email, username: username)
            }
        }
    }
    
//    func fetchFavorites() {
//        guard let userId = Auth.auth().currentUser?.uid else { return }
//
//        db.collection("users").document(userId).collection("favorites").getDocuments { [weak self] snapshot, error in
//            if let error = error {
//                self?.errorMessage = error.localizedDescription
//                return
//            }
//
//            guard let documents = snapshot?.documents else { return }
//            var fetchedFavorites: [Song] = []
//            for document in documents {
//                let data = document.data()
//                if let id = data["id"] as? String,
//                   let title = data["title"] as? String,
//                   let artist = data["artist"] as? String,
//                   let description = data["description"] as? String,
//                   let localAudioname = data["localAudioname"] as? String {
//                    let song = Song(
//                        id: id,
//                        artist: artist,
//                        title: title,
//                        description: description,
//                        localAudioname: localAudioname
//                    )
//                    fetchedFavorites.append(song)
//                }
//            }
//            DispatchQueue.main.async {
//                self?.favorites = fetchedFavorites
//            }
//        }
//    }
}
