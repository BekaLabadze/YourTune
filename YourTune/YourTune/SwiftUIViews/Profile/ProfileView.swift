//
//  ProfileView.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewModel()
    @StateObject var playListManager = PlayListManager.shared
    @EnvironmentObject var themeManager: ThemeManager
    @State private var shouldNavigateToLogin = false
    @State var isPresented: Bool = false
    @State var selectedPlaylist: Playlist?
    @State private var isDarkModeToggle: Bool

    init() {
        _isDarkModeToggle = State(initialValue: ThemeManager.shared.isDarkMode)
    }

    var body: some View {
        ZStack {
            themeManager.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack {
                    ZStack {
                        Image("profile_background")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 220)
                            .clipped()

                        VStack(spacing: 10) {
                            Image("profile_picture")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 110, height: 110)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .shadow(radius: 10)
                            
                            Text(SessionProvider.shared.user?.username ?? "Loading...")
                                .font(.title3)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.bottom, 5)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Your Playlists")
                            .font(.title2)
                            .foregroundColor(themeManager.textColor)
                        Spacer()
                        Button(action: {
                            isPresented = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .foregroundColor(themeManager.isDarkMode ? .white : .black)
                        }
                    }
                    .padding(.horizontal)

                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(playListManager.playListArray, id: \.self) { playList in
                                Button(action: {
                                    selectedPlaylist = playList
                                }) {
                                    HStack {
                                        Image("default_cover")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 60, height: 60)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .shadow(radius: 5)

                                        Text(playList.name ?? "Untitled Playlist")
                                            .foregroundColor(themeManager.textColor)
                                            .font(.body)
                                            .bold()
                                            .lineLimit(1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding()
                                    .background(themeManager.isDarkMode ? Color.black.opacity(0.2) : Color.white.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 300)
                }
                .padding(.top, 5)

                Spacer()

                VStack(spacing: 20) {
                    VStack {
                        HStack {
                            Text(isDarkModeToggle ? "Switch to Light Mode" : "Switch to Dark Mode")
                                .foregroundColor(themeManager.textColor)
                                .font(.headline)
                            Spacer()
                            Toggle("", isOn: $isDarkModeToggle)
                                .toggleStyle(SwitchToggleStyle(tint: themeManager.isDarkMode ? .green : .gray))
                                .onChange(of: isDarkModeToggle) { newValue in
                                    themeManager.isDarkMode = newValue
                                    themeManager.objectWillChange.send()
                                }
                                .frame(width: 55)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(themeManager.isDarkMode ? Color.black.opacity(0.2) : Color.white.opacity(0.2))
                        )
                        .padding(.horizontal)
                    }

                    Button(action: {
                        viewModel.signOut()
                        shouldNavigateToLogin = true
                    }) {
                        Text("Logout")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(themeManager.buttonGradient)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 10)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(themeManager.isDarkMode ? Color.black.opacity(0.15) : Color.white.opacity(0.15))
                        .shadow(radius: 12)
                )
                .padding(.horizontal)
                .frame(maxHeight: 230)
                .padding(.bottom, 20)
            }
            .background(themeManager.backgroundGradient.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
        }
        .fullScreenCover(isPresented: $shouldNavigateToLogin) {
            LoginView()
        }
        .sheet(isPresented: $isPresented) {
            AddPlayListView(playListArray: $playListManager.playListArray, isPresented: $isPresented)
                .presentationDetents([.medium])
        }
        .fullScreenCover(item: $selectedPlaylist) { playlist in
            PlaylistDetailView(playlist: playlist)
        }
    }
}
