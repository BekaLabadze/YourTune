//
//  LoginView.swift
//  YourTune
//
//  Created by Beka on 12.01.25.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var email: String = "Test123@gmail.com"
    @State private var password: String = "test123"
        
    @StateObject var viewModel: LoginViewModel = LoginViewModel()

        var body: some View {
            NavigationView {
                ZStack {
                    themeManager.backgroundGradient
                    .edgesIgnoringSafeArea(.all)

                    VStack {
                        VStack(spacing: -10) {
                            HStack {
                                Text("🎵")
                                    .font(.system(size: 80, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.green)
                                    .shadow(color: Color.green.opacity(0.6), radius: 10, x: 0, y: 5)
                                    .padding(.top, 65)
                                Text("Your")
                                    .font(.system(size: 60, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.white)
                                Text("Tune")
                                    .font(.system(size: 60, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.green)
                                    .padding(EdgeInsets(top: 100, leading: -100, bottom: 0, trailing: 0))
                            }
                        }
                        .padding(.top, 50)

                        Spacer().frame(height: 50)

                        VStack(spacing: 16) {
                            TextField("", text: $email, prompt: Text("Email or username").foregroundColor(Color(red: 0.70, green: 0.70, blue: 0.70)))
                                .padding()
                                .foregroundColor(Color.white)
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color(red: 0.22, green: 0.22, blue: 0.22)))
                            
                            SecureField("", text: $password, prompt: Text("Password").foregroundColor(Color(red: 0.70, green: 0.70, blue: 0.70)))
                                .padding()
                                .foregroundColor(Color.white)
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color(red: 0.22, green: 0.22, blue: 0.22)))
                        }
                        .padding(.horizontal)

                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(Color.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        Button {
                            viewModel.loginUser(email: email, password: password)
                        } label: {
                            Text("Log in")
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

                            Button {
                            } label: {
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

                        NavigationLink(destination: SignUpView()) {
                            Text("Don't have an account? Sign up")
                                .foregroundColor(Color.green)
                                .fontWeight(.semibold)
                        }
                        .padding(.bottom, 20)
                    }
                    .padding()
                    .navigationViewStyle(StackNavigationViewStyle())
                    .fullScreenCover(isPresented: $viewModel.isLoggedIn) {
                        MainTabView()
                            .environmentObject(themeManager)
                    }

                    if viewModel.showNotification {
                        ToastView(message: "Login Successful!", backgroundColor: Color.green)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .zIndex(1)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        viewModel.showNotification = false
                                    }
                                }
                            }
                    }

                    if viewModel.failedLogin {
                        ToastView(message: "Login Failed", backgroundColor: Color.red)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .zIndex(1)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        viewModel.failedLogin = false
                                    }
                                }
                            }
                    }
                }
            }
        }

        private func signInWithGoogle() {
            guard let presentingViewController = UIApplication.shared.windows.first?.rootViewController else { return }
            viewModel.signInWithGoogle(presenting: presentingViewController) { success, error in
                if success {
                    viewModel.showNotification = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        viewModel.isLoggedIn = true
                    }
                } else if let error = error {
                    viewModel.errorMessage = error.localizedDescription
                    viewModel.failedLogin = true
                }
            }
        }
    }
