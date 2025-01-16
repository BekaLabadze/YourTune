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
        let seasonsVC = SeasonsViewController()
        return seasonsVC
    }

    func updateUIViewController(_ uiViewController: SeasonsViewController, context: Context) {
        
    }
}
