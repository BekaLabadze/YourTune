//
//  PlayListViewModel.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import Foundation

final class PlayListViewModel {
    var playlists: [Playlist] = []
    var selectedSong: Song?
    
    init(playlists: [Playlist] = [], selectedSong: Song?) {
        self.playlists = playlists
        self.selectedSong = selectedSong
    }
    
    
    func addSongToPlaylist(_ playlist: Playlist) {
        guard let song = selectedSong else {
            print("Error: No selected song to add.")
            return
        }

        if let index = PlayListManager.shared.playListArray.firstIndex(where: { $0.id == playlist.id }) {
            var targetPlaylist = PlayListManager.shared.playListArray[index]

            if var songs = targetPlaylist.playListSongs {
                if !songs.contains(where: { $0.id == song.id }) {
                    songs.append(song)
                    targetPlaylist.playListSongs = songs
                    PlayListManager.shared.playListArray[index] = targetPlaylist
                } else {
                    print("Song already exists in the playlist")
                }
            } else {
                targetPlaylist.playListSongs = [song]
                PlayListManager.shared.playListArray[index] = targetPlaylist
            }
        } else {
            print("Error: Playlist not found in PlayListManager.")
        }
    }
}
