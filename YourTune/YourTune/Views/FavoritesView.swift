//
//  FavoritesView.swift
//  YourTune
//
//  Created by Beka on 16.01.25.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userViewModel: UserViewModel
    @ObservedObject var viewModel: FavoritesViewModel
    
    var body: some View {
        ZStack {
            themeManager.backgroundGradient
                .ignoresSafeArea(.all)

            VStack {
                if userViewModel.favorites.isEmpty {
                    Text("No favorite songs yet!")
                        .font(.headline)
                        .foregroundColor(themeManager.textColor)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(themeManager.isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.1))
                        )
                        .padding()
                } else {
                    List {
                        ForEach(userViewModel.favorites, id: \.id) { song in
                            if let (episodeID, tvShowID) = viewModel.findIDs(for: song) {
                                FavoritesRow(
                                    song: song,
                                    episodeID: episodeID,
                                    tvShowID: tvShowID,
                                    onPlayTapped: {},
                                    onRowTapped: {}
                                )
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(themeManager.backgroundGradient)
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                let song = userViewModel.favorites[index]
                                if let (episodeID, tvShowID) = viewModel.findIDs(for: song) {
                                    userViewModel.removeFavorite(song: song, in: episodeID, of: tvShowID)
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .padding()
        }
        .navigationTitle("Favorites")
        .toolbarBackground(themeManager.backgroundGradient, for: .tabBar)
    }
}
