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
import GoogleSignIn
import SwiftUI

final class SignUpViewModel: ObservableObject {
    @Published var user: User?
    @Published var errorMessage: String?
    @Published var showNotification: Bool = false
    @Published var notificationMessage: String = ""
    @Published var notificationColor: Color = .green
    
    private let db = Firestore.firestore()
    @Published var isAuthenticated = false
    
    func signUp(email: String, password: String, username: String, completion: @escaping (Bool) -> Void) {
        guard validateEmail(email), validatePassword(password), validateUsername(username) else {
            completion(false)
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                completion(false)
                return
            }

            guard let userId = authResult?.user.uid else {
                completion(false)
                return
            }

            let userData: [String: Any] = [
                "email": email,
                "username": username,
                "createdAt": Timestamp()
            ]

            self?.db.collection("users").document(userId).setData(userData) { error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    self?.isAuthenticated = true
                    self?.fetchUser()
                    completion(true)
                }
            }
        }
    }

    func signInWithGoogle(presenting viewController: UIViewController, completion: @escaping (Bool, Error?) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(false, NSError(domain: "Missing Client ID", code: -1, userInfo: nil))
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { signInResult, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.showNotification = true
                    self.notificationMessage = "Google Sign-In failed"
                    self.notificationColor = .red
                }
                completion(false, error)
                return
            }
            
            guard let user = signInResult?.user,
                  let idToken = user.idToken?.tokenString else {
                DispatchQueue.main.async {
                    self.showNotification = true
                    self.notificationMessage = "Google Sign-In failed"
                    self.notificationColor = .red
                }
                completion(false, NSError(domain: "Google Sign-In failed", code: -1, userInfo: nil))
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { _, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.showNotification = true
                        self.notificationMessage = "Sign-In failed"
                        self.notificationColor = .red
                    }
                    completion(false, error)
                    return
                }
                
                DispatchQueue.main.async {
                    self.createGoogleUserIfNeeded(user: user)
                    self.fetchUser()
                    SessionProvider.shared.fetchFavorites()
                    self.showNotification = true
                    self.notificationMessage = "Login Successful!"
                    self.notificationColor = .green
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.showNotification = false
                        completion(true, nil)
                    }
                }
            }
        }
    }

    
    func createGoogleUserIfNeeded(user: GIDGoogleUser) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            
            if document?.exists == false {
                guard let profile = user.profile else {
                    self?.errorMessage = "Google profile data is missing"
                    return
                }
                
                let userData: [String: Any] = [
                    "email": profile.email,
                    "username": profile.name,
                    "createdAt": Timestamp()
                ]
                
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
}
