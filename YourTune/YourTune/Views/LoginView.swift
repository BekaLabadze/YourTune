//
//  LoginView.swift
//  YourTune
//
//  Created by Beka on 12.01.25.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isLoggedIn: Bool = false
    @State private var showNotification: Bool = false
    @State private var failedLogin: Bool = false

    var body: some View {
        NavigationView {
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

                VStack {
                    VStack(spacing: -10) {
                    HStack {
                            Text("🎵")
                                .font(.system(size: 80, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.purple, Color.cyan]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: .cyan.opacity(0.6), radius: 10, x: 0, y: 5)
                                .padding(.top, 65)
                            
                            Text("Your")
                                .font(.system(size: 60, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.purple, Color.green]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: .green.opacity(0.6), radius: 10, x: 0, y: 5)
                        
                        Text("Tune")
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.purple, Color.cyan]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .cyan.opacity(0.6), radius: 10, x: 0, y: 5)
                            .padding(EdgeInsets(top: 100, leading: -100, bottom: 0, trailing: 0))

                        }
                    }
                    .padding(.top, 50)

                    Spacer().frame(height: 50)

                    VStack(spacing: 16) {
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
                                            gradient: Gradient(colors: [Color.cyan, Color.purple]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 1
                                    )
                            )

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
                    .padding(.horizontal)

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Button(action: loginUser) {
                        Text("Login")
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
                    .padding(.horizontal)
                    .padding(.top, 20)

                    NavigationLink("Don't have an account? Sign Up", destination: SignUpView())
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.cyan, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .padding(.top, 10)

                    Spacer()
                }
                .padding(.top, 50)
                .navigationViewStyle(StackNavigationViewStyle())
                .fullScreenCover(isPresented: $isLoggedIn) {
//                    MainTabView()
                }

                if showNotification {
                    ToastView(message: "Login Successful!", backgroundColor: .green)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(1)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showNotification = false
                                }
                            }
                        }
                }

                if failedLogin {
                    ToastView(message: "Login Failed", backgroundColor: .red)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(1)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    failedLogin = false
                                }
                            }
                        }
                }
            }
        }
    }

    private func loginUser() {
        guard !email.isEmpty, !password.isEmpty else {
            failedLogin = true
            errorMessage = "Please fill in both fields."
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                failedLogin = true
            } else {
                errorMessage = nil
                showNotification = true

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    isLoggedIn = true
                }
            }
        }
    }
}
