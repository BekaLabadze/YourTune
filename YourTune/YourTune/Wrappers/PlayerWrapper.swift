//
//  PlayerWrapper.swift
//  YourTune
//
//  Created by Beka on 26.01.25.
//

import SwiftUI

struct PlayerWrapper: UIViewControllerRepresentable {
    var selectedSong: Song
    var songArray: [Song]
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> Player {
        let playerVC = Player()
        playerVC.selectedSong = selectedSong
        playerVC.songArray = songArray
        playerVC.isFromSwiftUI = true
        playerVC.dismissAction = { dismiss() }
        return playerVC
    }

    func updateUIViewController(_ uiViewController: Player, context: Context) {
        uiViewController.selectedSong = selectedSong
        uiViewController.songArray = songArray
    }
}
