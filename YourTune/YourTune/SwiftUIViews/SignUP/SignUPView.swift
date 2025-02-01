//
//  SignUPView.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var showNotification = false
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject var viewModel: SignUpViewModel = SignUpViewModel()

    var body: some View {
        ZStack {
            themeManager.backgroundGradient.ignoresSafeArea()
            if viewModel.showNotification {
                ToastView(message: viewModel.notificationMessage, backgroundColor: viewModel.notificationColor)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }
            VStack {
                
                Spacer(minLength: 0)

                VStack(spacing: -10) {
                    HStack {
                        Text("🎵")
                            .font(.system(size: 80, weight: .bold, design: .rounded))
                            .foregroundColor(Color.green)
                            .shadow(color: themeManager.isDarkMode ? Color.green.opacity(0.6) : Color.black, radius: 10, x: 0, y: 5)
                            .padding(.top, 65)
                        Text("Your")
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundColor(themeManager.isDarkMode ? Color.white : Color.black)
                        Text("Tune")
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundColor(themeManager.isDarkMode ? Color.green : Color.green)
                            .padding(EdgeInsets(top: 100, leading: -100, bottom: 0, trailing: 0))
                    }
                }
                .padding(.top, 20)

                Spacer().frame(height: 50)

                VStack(spacing: 16) {
                    TextField("", text: $username, prompt: Text("Username")
                        .foregroundColor(Color(red: 0.70, green: 0.70, blue: 0.70)))
                        .padding()
                        .foregroundColor(themeManager.isDarkMode ? Color.white : Color.black)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(themeManager.isDarkMode ? Color(red: 0.22, green: 0.22, blue: 0.22) : Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(themeManager.isDarkMode ? Color.clear : Color.green, lineWidth: 2)
                                )
                        )

                    TextField("", text: $email, prompt: Text("Email")
                        .foregroundColor(Color(red: 0.70, green: 0.70, blue: 0.70)))
                        .padding()
                        .foregroundColor(themeManager.isDarkMode ? Color.white : Color.black)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(themeManager.isDarkMode ? Color(red: 0.22, green: 0.22, blue: 0.22) : Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(themeManager.isDarkMode ? Color.clear : Color.green, lineWidth: 2)
                                )
                        )

                    SecureField("", text: $password, prompt: Text("Password")
                        .foregroundColor(Color(red: 0.70, green: 0.70, blue: 0.70)))
                        .padding()
                        .foregroundColor(themeManager.isDarkMode ? Color.white : Color.black)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(themeManager.isDarkMode ? Color(red: 0.22, green: 0.22, blue: 0.22) : Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(themeManager.isDarkMode ? Color.clear : Color.green, lineWidth: 2)
                                )
                        )
                }
                .padding(.horizontal)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(Color.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button {
                    viewModel.signUp(email: email, password: password, username: username) { success in
                        if success {
                            withAnimation {
                                showNotification = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation {
                                    showNotification = false
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }
                } label: {
                    Text("Sign Up")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(Color.black)
                        .cornerRadius(50)
                        .font(.headline)
                }
                .padding(.horizontal)
                .padding(.top, 20)

                Spacer()

                VStack {
                    Text("Or continue with")
                        .foregroundColor(Color(red: 0.33, green: 0.33, blue: 0.33))
                        .font(.footnote)
                        .padding(.bottom, 10)

                    
                    Button(action: signInWithGoogle) {
                        HStack {
                            Image(systemName: "g.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("Continue with Google")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(Color.black)
                        .cornerRadius(50)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "applelogo")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("Continue with Apple")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(Color.black)
                        .cornerRadius(50)
                    }
                    .padding(.horizontal)
                }

                Spacer()

                Divider()
                    .background(Color(red: 0.33, green: 0.33, blue: 0.33))
                    .padding(.horizontal)

                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("Already have an account? Login")
                        .foregroundColor(Color.green)
                        .fontWeight(.semibold)
                }
                .padding(.bottom, 20)
            }
            .padding()
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $viewModel.isAuthenticated) {
                MainTabView()
                    .environmentObject(themeManager)
            }
        }
        
    }
    
    private func signInWithGoogle() {
        guard let presentingViewController = UIApplication.shared.windows.first?.rootViewController else { return }
        viewModel.signInWithGoogle(presenting: presentingViewController) { success, error in
            if success {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    showNotification = true
                    viewModel.isAuthenticated = true
                }
            } else if let error = error {
                viewModel.errorMessage = error.localizedDescription
                viewModel.isAuthenticated = false
            }
        }
    }
}
