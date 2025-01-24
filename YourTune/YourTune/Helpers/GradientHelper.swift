//
//  GradientHelper.swift
//  YourTune
//
//  Created by Beka on 24.01.25.
//

import UIKit

class GradientHelper {
    static let navigationBarColors: [UIColor] = [
        UIColor(displayP3Red: 0.05, green: 0.05, blue: 0.2, alpha: 1.0),
        UIColor(displayP3Red: 0.1, green: 0.0, blue: 0.3, alpha: 1.0),
        UIColor(displayP3Red: 0.2, green: 0.0, blue: 0.5, alpha: 1.0)
    ]
    
    static func applyShinyDarkGradient(to view: UIView) {
        if ThemeManager.shared.isDarkMode {
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = navigationBarColors.map { $0.cgColor }
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer.frame = view.bounds
            view.layer.insertSublayer(gradientLayer, at: 0)
        } else {
            view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
            view.backgroundColor = .white
        }
    }
    
    static func applyShinyDarkGradientToNavigationBar(_ navigationBar: UINavigationBar) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = navigationBarColors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 88))
        
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundImage = gradientImage
        appearance.shadowColor = .clear
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.isTranslucent = true
    }
    
    static func applyGradientBackground(to tableView: UITableView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.05, green: 0.05, blue: 0.2, alpha: 1.0).cgColor,
            UIColor(red: 0.1, green: 0.0, blue: 0.3, alpha: 1.0).cgColor,
            UIColor(red: 0.2, green: 0.0, blue: 0.5, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.frame = tableView.bounds
        
        let gradientBackgroundView = UIView(frame: tableView.bounds)
        gradientBackgroundView.layer.insertSublayer(gradientLayer, at: 0)
        
        tableView.backgroundView = gradientBackgroundView
        tableView.backgroundColor = .clear
    }
}

class NavigationBarHelper {
    static func applyCustomTitleAppearance(
        to navigationBar: UINavigationBar,
        titleColor: UIColor = .white,
        titleFont: UIFont = UIFont.systemFont(ofSize: 20, weight: .bold),
        backgroundColor: UIColor? = nil
    ) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()

        appearance.titleTextAttributes = [
            .foregroundColor: titleColor,
            .font: titleFont
        ]
        
        if let backgroundColor = backgroundColor {
            appearance.backgroundColor = backgroundColor
        }

        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
    }
}
