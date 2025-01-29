//
//  LoginViewModel.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import FirebaseFirestore

final class LoginViewModel: ObservableObject {
    
    @Published var failedLogin: Bool = false
    @Published var errorMessage: String?
    @Published var showNotification: Bool = false
    @Published var isLoggedIn: Bool = false
    @Published var isAuthenticated = false
    
    private let db = Firestore.firestore()
    
    func signInWithGoogle(presenting viewController: UIViewController, completion: @escaping (Bool, Error?) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(false, NSError(domain: "Missing Client ID", code: -1, userInfo: nil))
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { signInResult, error in
            if let error = error {
                completion(false, error)
                return
            }
            
            guard let user = signInResult?.user,
                  let idToken = user.idToken?.tokenString else {
                completion(false, NSError(domain: "Google Sign-In failed", code: -1, userInfo: nil))
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { _, error in
                if let error = error {
                    completion(false, error)
                    return
                }
                self.createGoogleUserIfNeeded(user: user)
                completion(true, nil)
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
                    "email": profile.email ?? "",
                    "username": profile.name ?? "Unknown",
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
    
//    func fetchUser() {
//        guard let userId = Auth.auth().currentUser?.uid else { return }
//        db.collection("users").document(userId).getDocument { [weak self] document, error in
//            if let error = error {
//                self?.errorMessage = error.localizedDescription
//                return
//            }
//            if let data = document?.data(),
//               let email = data["email"] as? String,
//               let username = data["username"] as? String {
//                self?.user = User(id: userId, email: email, username: username)
//                self?.fetchFavorites()
//            }
//        }
//    }
    
    func loginUser(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            failedLogin = true
            errorMessage = "Please fill in both fields."
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self else { return }
            if let error = error {
                errorMessage = error.localizedDescription
                failedLogin = true
            } else {
                errorMessage = nil
                showNotification = true
                self.fetchUser()
                SessionProvider.shared.fetchFavorites()

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.isLoggedIn = true
                }
            }
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
                let user = User(id: userId, email: email, username: username)
                SessionProvider.shared.setUser(user)
            }
        }
    }
}
