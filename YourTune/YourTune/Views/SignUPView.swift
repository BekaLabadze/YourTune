//
//  SignUPView.swift
//  YourTune
//
//  Created by Beka on 12.01.25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isPulsating: Bool = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.2),
                    Color(red: 0.1, green: 0.0, blue: 0.3),
                    Color(red: 0.2, green: 0.0, blue: 0.5)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            .overlay(
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.purple.opacity(0.3),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 5,
                            endRadius: 300
                        )
                    )
                    .frame(width: 400, height: 400)
                    .blur(radius: 50)
                    .offset(x: -150, y: -300)
            )
            .overlay(
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.cyan.opacity(0.3),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 5,
                            endRadius: 300
                        )
                    )
                    .frame(width: 300, height: 300)
                    .blur(radius: 50)
                    .offset(x: 150, y: 300)
            )

            VStack(spacing: 20) {
                Text("Sign Up")
                    .font(.system(size: 50, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.purple, Color.cyan]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .cyan.opacity(0.6), radius: 10, x: 0, y: 5)
                    .padding(.bottom, 30)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Username")
                        .foregroundStyle(.white)
                        .font(.headline)

                    TextField("", text: $username, prompt: Text("Enter your username").foregroundColor(.white))
                        .padding()
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.cyan, Color.purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 1
                                )
                        )

                    Text("Email")
                        .foregroundStyle(.white)
                        .font(.headline)

                    TextField("", text: $email, prompt: Text("Enter your email").foregroundColor(.white))
                        .padding()
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.purple, Color.cyan]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 1
                                )
                        )

                    Text("Password")
                        .foregroundStyle(.white)
                        .font(.headline)

                    SecureField("", text: $password, prompt: Text("Enter your password").foregroundColor(.white))
                        .padding()
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.purple, Color.cyan]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }

                Button(action: registerUser) {
                    Text("Sign Up")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.purple, Color.cyan]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(color: Color.purple.opacity(0.4), radius: 10, x: 0, y: 5)
                }

                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("Already have an account? Login")
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.cyan, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .padding(.top, 10)
                }

                Spacer()
            }
            .padding()
            .navigationBarBackButtonHidden(true)
        }
    }

    private func registerUser() {
        guard !username.isEmpty, !email.isEmpty, password.count >= 6 else {
            errorMessage = "Please fill in all fields and ensure the password is at least 6 characters."
            return
        }

        guard email.contains("@") else {
            errorMessage = "Please enter a valid email."
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }

            if let user = result?.user {
                let db = Firestore.firestore()
                db.collection("users").document(user.uid).setData([
                    "username": username,
                    "email": email,
                    "createdAt": FieldValue.serverTimestamp()
                ]) { error in
                    if let error = error {
                        errorMessage = "Error saving user data: \(error.localizedDescription)"
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
