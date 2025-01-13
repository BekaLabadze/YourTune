//
//  UserViewModel.swift
//  YourTune
//
//  Created by Beka on 13.01.25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class UserViewModel: ObservableObject {
    @Published var user: User?
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    
    private let db = Firestore.firestore()
    
    init() {
        fetchUser()
    }
    
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
    
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            self?.isAuthenticated = true
            self?.fetchUser()
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            user = nil
        } catch {
            errorMessage = "Error signing out: \(error.localizedDescription)"
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
}
