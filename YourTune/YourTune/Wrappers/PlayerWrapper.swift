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
    
    func makeUIViewController(context: Context) -> PlayerViewController {
        let playerViewModel = PlayerViewModel(
            songArray: songArray,
            selectedSong: selectedSong
        )
        let playerVC = PlayerViewController(
            viewModel: playerViewModel,
            isFromSwiftUI: true
        )
        playerVC.dismissAction = { dismiss() }
        return playerVC
    }

    func updateUIViewController(_ uiViewController: PlayerViewController, context: Context) {
        uiViewController.viewModel.selectedSong = selectedSong
        uiViewController.viewModel.songArray = songArray
    }
}
