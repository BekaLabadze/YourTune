//
//  GradientHelper.swift
//  YourTune
//
//  Created by Beka on 24.01.25.
//

import UIKit

class GradientHelper {
    static let spotifyDarkModeGradient: [UIColor] = [
        UIColor.black,
        UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 1.0),
        UIColor(red: 0.10, green: 0.08, blue: 0.08, alpha: 1.0)
    ]

    static func applyShinyDarkGradient(to view: UIView) {
        if ThemeManager.shared.isDarkMode {
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = spotifyDarkModeGradient.map { $0.cgColor }
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer.frame = view.bounds
            view.layer.insertSublayer(gradientLayer, at: 0)
        } else {
            view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
            view.backgroundColor = .adjustedWhite
        }
    }

    static func applyGradientBackground(to tableView: UITableView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = spotifyDarkModeGradient.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.frame = tableView.bounds
        
        let gradientBackgroundView = UIView(frame: tableView.bounds)
        gradientBackgroundView.layer.insertSublayer(gradientLayer, at: 0)
        
        tableView.backgroundView = gradientBackgroundView
        tableView.backgroundColor = .clear
    }
}
