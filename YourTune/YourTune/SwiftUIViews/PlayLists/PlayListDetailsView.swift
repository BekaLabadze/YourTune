//
//  PlayListDetailsView.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import SwiftUI

struct PlaylistDetailView: View {
    var playlist: Playlist
    @State private var selectedSong: Song?
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isPlayerPresented = false

    var body: some View {
        ZStack {
            themeManager.backgroundGradient
                .ignoresSafeArea()

            VStack {
                Text(playlist.name ?? "Untitled Playlist")
                    .font(.largeTitle)
                    .foregroundColor(themeManager.textColor)
                    .padding()

                if let songs = playlist.playListSongs, !songs.isEmpty {
                    List(songs, id: \.self) { song in
                        Button(action: {
                            selectedSong = song
                            print("Selected Song: \(selectedSong?.title ?? "No Title")")
                            isPlayerPresented = true
                            print("isPlayerPresented: \(isPlayerPresented)")
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
                } else {
                    Text("No Songs in Playlist")
                        .foregroundColor(themeManager.textColor)
                        .padding()
                }
            }
            .padding()
        }
        .fullScreenCover(isPresented: $isPlayerPresented) {
            ZStack {
                PlayerWrapper(selectedSong: selectedSong!, songArray: playlist.playListSongs ?? [])
            }
            .ignoresSafeArea()
        }
        .onChange(of: selectedSong) { newValue in
            if let selectedSong = newValue {
                print("Presenting PlayerWrapper for song: \(selectedSong.title)")
                isPlayerPresented = true
            } else {
                print("Error: selectedSong is nil when triggering the sheet")
            }
        }
    }
}
