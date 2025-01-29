//
//  PlayListSongsViewModel.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import Foundation

final class PlaylistSongsViewModel {
    var playlist: Playlist?
    
    init(playlist: Playlist? = nil) {
        self.playlist = playlist
    }
    
    var playlistSongsCount: Int? {
        playlist?.playListSongs?.count ?? nil
    }
    
    func getSong(on index: Int) -> Song? {
        playlist?.playListSongs?[index]
    }
}
