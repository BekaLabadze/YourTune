//
//  PlayListManager.swift
//  YourTune
//
//  Created by Beka on 26.01.25.
//

import SwiftUI

class PlayListManager: ObservableObject {
    static let shared = PlayListManager()
    
    @Published var playListArray: [Playlist] = []
    private init() {}
    
    func fetchSong(song: Song) {
        
    }
}

