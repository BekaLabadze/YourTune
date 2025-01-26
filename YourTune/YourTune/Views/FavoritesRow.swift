//
//  FavoritesRow.swift
//  YourTune
//
//  Created by Beka on 26.01.25.
//

import SwiftUI

struct FavoritesRow: View {
    let song: Song
    let episodeID: String
    let tvShowID: String
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var themeManager: ThemeManager
    var onPlayTapped: () -> Void
    var onRowTapped: () -> Void

    var body: some View {
        ZStack {
            HStack {
                if let urlString = song.album?.cover.absoluteString {
                    AsyncImage(url: URL(string: "\(urlString)?cachebuster=\(UUID().uuidString)")) { result in
                        switch result {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        case .failure:
                            Image(systemName: "music.note.list")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(themeManager.isDarkMode ? .gray : .black)
                        default:
                            ProgressView()
                                .frame(width: 60, height: 60)
                        }
                    }
                }

                VStack(alignment: .leading) {
                    Text(song.title)
                        .font(.headline)
                        .foregroundColor(themeManager.textColor)
                    Text(song.artist)
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryTextColor)
                }
                Spacer()

                Button(action: {
                    userViewModel.toggleFavorite(for: song, in: episodeID, of: tvShowID)
                }) {
                    Image(systemName: userViewModel.isFavorite(song) ? "heart.fill" : "heart")
                        .foregroundColor(userViewModel.isFavorite(song) ? .red : themeManager.textColor)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding()
            .onTapGesture {
                onRowTapped()
            }
        }
        .frame(height: 80)
        .padding(.horizontal)
    }
}
