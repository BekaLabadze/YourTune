//
//  PlayListDetailsView.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import SwiftUI

struct PlaylistDetailView: View {
    var playlist: Playlist
    @ObservedObject var viewModel: PlaylistViewModelSwiftUI
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var selectedSongWrapper = SelectedSongWrapper()
    @State private var isPlayerPresented = false

    var body: some View {
        ZStack {
            themeManager.backgroundGradient.ignoresSafeArea()

            VStack {
                Text(playlist.name)
                    .font(.largeTitle)
                    .foregroundColor(themeManager.textColor)
                    .padding()

                if viewModel.songs.isEmpty {
                    Text("No Songs in Playlist")
                        .foregroundColor(themeManager.textColor)
                        .padding()
                } else {
                    List(viewModel.songs, id: \.id) { song in
                        Button(action: {
                            selectedSongWrapper.selectedSong = song
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    isPlayerPresented = true
                                }
                        }) {
                            HStack {
                                Text(song.title)
                                    .foregroundColor(themeManager.textColor)
                                Spacer()
                                Text(song.artist)
                                    .foregroundColor(themeManager.secondaryTextColor)
                            }
                        }
                        .listRowBackground(themeManager.backgroundGradient)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .padding()
        }
            .onAppear {
                viewModel.fetchSongs(for: playlist.id)
                viewModel.fetchAndMapSongs()
                
        }
        .sheet(isPresented: $isPlayerPresented) {
            if let song = selectedSongWrapper.selectedSong {
                PlayerWrapper(selectedSong: song, songArray: viewModel.songs)
                    .ignoresSafeArea()
                    .onAppear {
                        print("Song: \(song.title)")
                        print("Song: \(String(describing: song.preview))")
                        print("Song: \(song.album?.cover)")
                    }
            } else {
                Text("No song selected")
            }
        }
    }
}
