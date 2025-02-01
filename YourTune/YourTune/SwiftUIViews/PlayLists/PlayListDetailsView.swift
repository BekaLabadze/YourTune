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
    @State private var showDeletePlaylistAlert = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            themeManager.backgroundGradient.ignoresSafeArea()

            VStack {
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(themeManager.textColor)
                            .padding()
                    }
                    Spacer()
                    Button(action: { showDeletePlaylistAlert = true }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .padding()
                    }
                }

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
                        HStack {
                            Button(action: {
                                selectedSongWrapper.selectedSong = song
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    isPlayerPresented = true
                                }
                            }) {
                                VStack(alignment: .leading) {
                                    Text(song.title)
                                        .foregroundColor(themeManager.textColor)
                                    Text(song.artist)
                                        .foregroundColor(themeManager.secondaryTextColor)
                                }
                            }

                            Spacer()

                            Button(action: {
                                viewModel.deleteSongFromPlaylist(playlistID: playlist.id, songID: song.id) { success in
                                    if success {
                                        viewModel.fetchSongs(for: playlist.id)
                                    }
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .padding()
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
            } else {
                Text("No song selected")
            }
        }
        .alert(isPresented: $showDeletePlaylistAlert) {
            Alert(
                title: Text("Delete Playlist"),
                message: Text("Are you sure you want to delete this playlist?"),
                primaryButton: .destructive(Text("Delete")) {
                    viewModel.deletePlaylist(playlistID: playlist.id) { success in
                        if success {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}
