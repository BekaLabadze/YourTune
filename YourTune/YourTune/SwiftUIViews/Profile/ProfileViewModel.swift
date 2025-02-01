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
import Firebase
import FirebaseStorage

class ProfileViewModel: ObservableObject {
    @Published var profileImageURL: String?
    @Published var errorMessage: String?

    init() {
        fetchProfileImage()
    }

    func uploadProfileImage(image: UIImage, completion: @escaping (Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("profile_images/\(userID).jpg")

        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }

        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Upload error: \(error.localizedDescription)")
                completion(false)
                return
            }

            storageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    print("Error getting download URL")
                    completion(false)
                    return
                }

                self.createOrUpdateUserProfile(url: downloadURL.absoluteString)
                completion(true)
            }
        }
    }

    func createOrUpdateUserProfile(url: String) {
        guard let userID = Auth.auth().currentUser?.uid, let email = Auth.auth().currentUser?.email else { return }
        let userRef = Firestore.firestore().collection("users").document(userID)

        userRef.getDocument { snapshot, error in
            if let error = error {
                print("Error checking user document: \(error.localizedDescription)")
                return
            }

            if snapshot?.exists == true {
                userRef.updateData(["profileImageURL": url]) { error in
                    if let error = error {
                        print("Error updating profile image URL: \(error.localizedDescription)")
                    } else {
                        DispatchQueue.main.async {
                            self.profileImageURL = url
                        }
                    }
                }
            } else {
                userRef.setData([
                    "email": email,
                    "profileImageURL": url,
                    "createdAt": Timestamp(date: Date())
                ]) { error in
                    if let error = error {
                        print("Error creating user profile: \(error.localizedDescription)")
                    } else {
                        DispatchQueue.main.async {
                            self.profileImageURL = url
                        }
                    }
                }
            }
        }
    }

    func fetchProfileImage() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(userID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching profile image: \(error.localizedDescription)")
                return
            }
            if let data = snapshot?.data(), let url = data["profileImageURL"] as? String {
                DispatchQueue.main.async {
                    self.profileImageURL = url
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            SessionProvider.shared.setUser(nil)
        } catch {
            errorMessage = "Error signing out: \(error.localizedDescription)"
        }
    }
}
