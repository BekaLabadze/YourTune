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
                        .foregroundColor(themeManager.isDarkMode ? Color.white.opacity(0.7) : Color(red: 0.33, green: 0.33, blue: 0.33))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.22, green: 0.22, blue: 0.22))
                        )
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(viewModel.favorites, id: \.id) { song in
                                if let (episodeID, tvShowID) = viewModel.findIDs(for: song) {
                                    FavoritesRow(
                                        song: song,
                                        episodeID: episodeID,
                                        tvShowID: tvShowID,
                                        onPlayTapped: {},
                                        onRowTapped: {}
                                    )
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                }

                Spacer()
            }
        }
        .onAppear {
            viewModel.fetchTVShows()
        }
    }
}
