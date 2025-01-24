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
        SeasonsViewController(tvShow: tvShow, userViewModel: userViewModel)
    }

    func updateUIViewController(_ uiViewController: SeasonsViewController, context: Context) {
        uiViewController.tvShow = tvShow
        uiViewController.updateSeasons()
    }
}

