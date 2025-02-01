//
//  FavoritesView.swift
//  YourTune
//
//  Created by Beka on 16.01.25.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject var viewModel = FavoritesViewModel()
    @State private var showPlayer: Bool = false
    
    var body: some View {
        ZStack {
            themeManager.backgroundGradient
                .ignoresSafeArea()

            VStack {
                Text("Favorites")
                    .font(.largeTitle)
                    .foregroundColor(themeManager.isDarkMode ? Color.white : Color(red: 0.10, green: 0.10, blue: 0.10))
                    .padding(.top, 16)

                if viewModel.favorites.isEmpty {
                    Text("No favorite songs yet!")
                        .font(.headline)
                        .foregroundColor(themeManager.isDarkMode ? Color.white : Color.black)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(themeManager.isDarkMode ? Color.black.opacity(0.7) : Color.white)
                        )
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(viewModel.favorites, id: \.id) { song in
                                let ids = viewModel.findIDs(for: song)
                                if let episodeID = ids.episodeID, let tvShowID = ids.tvShowID {
                                    FavoritesRow(
                                        song: song,
                                        episodeID: episodeID,
                                        tvShowID: tvShowID,
                                        onPlayTapped: {},
                                        onRowTapped: {
                                            viewModel.selectedSongs = song
                                            showPlayer = true
                                        },
                                        onHeartTapped: {
                                            SessionProvider.shared.toggleFavorite(for: song, in: episodeID, of: tvShowID)
                                            viewModel.fetchFavorites()
                                        },
                                        isFavorite: SessionProvider.shared.isFavorite(song)
                                    )
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                }

                Spacer()
            }
            .sheet(isPresented: $showPlayer) {
                if let selectedSong = viewModel.selectedSongs {
                    PlayerWrapper(selectedSong: selectedSong, songArray: viewModel.favorites)
                        .ignoresSafeArea()
                }
            }
        }
        .onAppear {
            viewModel.fetchTVShows()
            viewModel.fetchFavorites()
        }
    }
}
