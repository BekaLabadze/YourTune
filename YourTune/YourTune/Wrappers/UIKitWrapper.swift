//
//  UIKitWrapper.swift
//  YourTune
//
//  Created by Beka on 16.01.25.
//

import SwiftUI
import UIKit

struct Wrapper: UIViewControllerRepresentable {
    var tvShow: TVShow
    var userViewModel: UserViewModel

    func makeUIViewController(context: Context) -> SeasonsViewController {
        SeasonsViewController(
            viewModel: .init(
                tvShow: tvShow,
                userViewModel: userViewModel
            )
        )
    }

    func updateUIViewController(_ uiViewController: SeasonsViewController, context: Context) {
        uiViewController.viewModel.tvShow = tvShow
        uiViewController.updateSeasons()
    }
}
