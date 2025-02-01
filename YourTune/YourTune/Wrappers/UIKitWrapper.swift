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

    func makeUIViewController(context: Context) -> SeasonsViewController {
        SeasonsViewController(
            viewModel: .init(
                tvShow: tvShow
            )
        )
    }

    func updateUIViewController(_ uiViewController: SeasonsViewController, context: Context) {
        uiViewController.viewModel.tvShow = tvShow
        uiViewController.updateSeasons()
    }
}
