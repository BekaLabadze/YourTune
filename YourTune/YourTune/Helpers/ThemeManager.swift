//
//  ThemeManager.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import SwiftUI
import UIKit

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    private init() {}
    
    @Published var isDarkMode: Bool = true {
        didSet {
            NotificationCenter.default.post(name: .themeChanged, object: nil)
            setupNavigationBarAppearance()
            setupTabBarAppearance()
        }
    }
    
    var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: isDarkMode
                ? [
                    Color.black,
                    Color(red: 0.10, green: 0.10, blue: 0.10),
                    Color(red: 0.13, green: 0.13, blue: 0.13).opacity(0.95)
                ]
                : [
                    Color.white,
                    Color.white
                ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var textColor: Color {
        isDarkMode ? Color.white : Color(red: 0.10, green: 0.08, blue: 0.08)
    }
    
    var secondaryTextColor: Color {
        isDarkMode ? Color.gray : Color(red: 0.33, green: 0.33, blue: 0.33)
    }
    
    var buttonGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: isDarkMode
                               ? [
                                Color(red: 0.12, green: 0.73, blue: 0.33),
                                Color(red: 0.10, green: 0.68, blue: 0.28)
                               ]
                               : [
                                Color(red: 0.12, green: 0.73, blue: 0.33),
                                Color(red: 0.10, green: 0.68, blue: 0.28)
                               ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    

    var uiKitBackgroundGradient: CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = isDarkMode
        ? [
            UIColor.black.cgColor,
            UIColor(red: 0.10, green: 0.10, blue: 0.10, alpha: 1.0).cgColor,
            UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 0.95).cgColor
        ]
        : [
            UIColor.white.cgColor,
            UIColor.white.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer
    }
    
    var uiKitTextColor: UIColor {
        return isDarkMode ? .white : UIColor(red: 0.10, green: 0.08, blue: 0.08, alpha: 1.0)
    }
    

    var uiKitButtonGradient: CAGradientLayer {
            let gradientLayer = CAGradientLayer()
            
            if isDarkMode {
                gradientLayer.colors = [
                    UIColor(red: 0.12, green: 0.73, blue: 0.33, alpha: 1.0).cgColor,
                    UIColor(red: 0.10, green: 0.68, blue: 0.28, alpha: 1.0).cgColor
                ]
            } else {
                gradientLayer.colors = [
                    UIColor(red: 0.12, green: 0.73, blue: 0.33, alpha: 1.0).cgColor,
                    UIColor(red: 0.12, green: 0.85, blue: 0.40, alpha: 1.0).cgColor
                ]
            }
            
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            return gradientLayer
        }
        
        func applyGradientToButton(_ button: UIButton) {
            let gradientLayer = self.uiKitButtonGradient
            gradientLayer.frame = button.bounds
            button.layer.insertSublayer(gradientLayer, at: 0)
        }
    
    func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = nil
        appearance.titleTextAttributes = [
            .foregroundColor: ThemeManager.shared.uiKitTextColor,
            .font: UIFont.boldSystemFont(ofSize: 20)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: ThemeManager.shared.uiKitTextColor,
            .font: UIFont.boldSystemFont(ofSize: 34)
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        if isDarkMode {
            let blendedColor = UIColor(red: 0.10, green: 0.10, blue: 0.10, alpha: 0.97)
            appearance.backgroundColor = blendedColor
        } else {
            print(isDarkMode)
            appearance.backgroundColor = UIColor.white
        }

        let selectedColor = UIColor(red: 0.12, green: 0.73, blue: 0.33, alpha: 1.0)
        let unselectedColor = UIColor.white.withAlphaComponent(0.85)

        appearance.stackedLayoutAppearance.normal.iconColor = unselectedColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: unselectedColor]

        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().tintColor = selectedColor
        UITabBar.appearance().unselectedItemTintColor = unselectedColor
    }
    
    var uiKitCellGradient: CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = isDarkMode
        ? [
            UIColor.black.cgColor,
            UIColor.darkGray.cgColor
        ]
        : [
            UIColor(hex: "#F3F3F3").cgColor,
            UIColor(hex: "#E0E0E0").cgColor 
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer
    }

    func applyGradientToCell(_ cell: UITableViewCell) {
        let gradientLayer = self.uiKitCellGradient
        gradientLayer.frame = cell.contentView.bounds
        gradientLayer.cornerRadius = 12
        if let existingGradient = cell.contentView.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
            existingGradient.colors = gradientLayer.colors
        } else {
            cell.contentView.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
    var tabBarGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: isDarkMode
                ? [
                    Color.black,
                    Color(red: 0.10, green: 0.10, blue: 0.10),
                    Color(red: 0.13, green: 0.13, blue: 0.13).opacity(0.95)
                ]
                : [
                    Color.white,
                    Color(red: 0.90, green: 0.90, blue: 0.90)
                ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var adjustedWhite: Color {
        isDarkMode ? Color.white : Color(red: 0.95, green: 0.95, blue: 0.95)
    }

    var uiKitAdjustedWhite: UIColor {
        isDarkMode ? UIColor.white : UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
    }
}
