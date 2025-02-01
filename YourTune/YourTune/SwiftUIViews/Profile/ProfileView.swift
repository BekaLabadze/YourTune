//
//  ProfileView.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel = PlaylistViewModelSwiftUI()
    @StateObject var profileViewModel = ProfileViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    @State private var shouldNavigateToLogin = false
    @State private var isPresented: Bool = false
    @State private var selectedPlaylist: Playlist?
    @State private var isDarkModeToggle = ThemeManager.shared.isDarkMode
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?

    init() {
        _isDarkModeToggle = State(initialValue: ThemeManager.shared.isDarkMode)
    }

    var body: some View {
        ZStack {
            themeManager.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                
                Spacer().frame(height: 20)
                
                ProfileHeaderView(profileImageURL: profileViewModel.profileImageURL, showImagePicker: $showImagePicker)
                
                Spacer().frame(height: 20)
                
                Text(SessionProvider.shared.user?.username ?? "Loading...")
                    .font(.title3)
                    .foregroundStyle(themeManager.isDarkMode ? Color.white : Color.black) 
                
                Spacer().frame(height: 60)
                
                PlaylistsSectionView(
                    playlists: viewModel.playlists,
                    themeManager: themeManager,
                    onPlaylistSelect: { selectedPlaylist = $0 },
                    onAddPlaylistTap: { isPresented = true }
                )

                Spacer()

                VStack(spacing: 20) {
                    ThemeToggleView(isDarkModeToggle: $isDarkModeToggle)
                        .environmentObject(themeManager)

                    LogoutButtonView {
                        profileViewModel.signOut()
                        shouldNavigateToLogin = true
                    }
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
            AddPlayListView(isPresented: $isPresented, viewModel: viewModel)
                .presentationDetents([.medium])
        }
        .sheet(item: $selectedPlaylist) { playlist in
            PlaylistDetailView(playlist: playlist, viewModel: viewModel)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .onChange(of: selectedImage) { newImage in
            if let newImage = newImage {
                profileViewModel.uploadProfileImage(image: newImage) { success in
                    if success {
                        print("Profile image updated successfully")
                    }
                }
            }
        }
        .onAppear {
            viewModel.startListeningForPlaylists()
        }
        .onDisappear {
            viewModel.stopListeningForPlaylists()
        }
    }
}



struct PlaylistsSectionView: View {
    let playlists: [Playlist]
    let themeManager: ThemeManager
    let onPlaylistSelect: (Playlist) -> Void
    let onAddPlaylistTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Your Playlists")
                    .font(.title2)
                    .foregroundColor(themeManager.textColor)
                Spacer()
                Button(action: onAddPlaylistTap) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(themeManager.isDarkMode ? .white : .black)
                }
            }
            .padding(.horizontal)

            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(playlists, id: \.id) { playlist in
                        Button(action: { onPlaylistSelect(playlist) }) {
                            HStack {
                                Image("default_cover")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(radius: 5)

                                Text(playlist.name)
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
    }
}
