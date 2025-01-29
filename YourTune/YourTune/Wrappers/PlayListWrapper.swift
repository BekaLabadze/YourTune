//
//  PlayListWrapper.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import SwiftUI

struct PlaylistSongsViewControllerWrapper: UIViewControllerRepresentable {
    let playlist: Playlist

    func makeUIViewController(context: Context) -> PlaylistSongsViewController {
        let viewController = PlaylistSongsViewController(
            viewModel: .init(playlist: playlist)
        )
        return viewController
    }

    func updateUIViewController(_ uiViewController: PlaylistSongsViewController, context: Context) {}
}
