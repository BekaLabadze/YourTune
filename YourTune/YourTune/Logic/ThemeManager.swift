//
//  ThemeManager.swift
//  YourTune
//
//  Created by Beka on 24.01.25.
//

import SwiftUI
import UIKit

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    private init() {}

    @Published var isDarkMode: Bool = true {
        didSet {
            NotificationCenter.default.post(name: .themeChanged, object: nil)
        }
    }

    var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: isDarkMode
                ? [
                    Color(red: 0.05, green: 0.05, blue: 0.2),
                    Color(red: 0.1, green: 0.0, blue: 0.3),
                    Color(red: 0.2, green: 0.0, blue: 0.5)
                ]
                : [Color.white, Color(white: 0.9)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var textColor: Color {
        isDarkMode ? .white : .black
    }

    var secondaryTextColor: Color {
        isDarkMode ? .gray : .black.opacity(0.7)
    }

    var buttonGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: isDarkMode
                ? [.blue, .purple, .pink]
                : [.gray, .gray.opacity(0.8)]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    var backgroundColor: some View {
        isDarkMode ? AnyView(backgroundGradient.ignoresSafeArea()) : AnyView(Color.white.ignoresSafeArea())
    }
    
    var uiKitBackgroundGradient: CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = isDarkMode
            ? [
                UIColor(red: 0.05, green: 0.05, blue: 0.2, alpha: 1).cgColor,
                UIColor(red: 0.1, green: 0.0, blue: 0.3, alpha: 1).cgColor,
                UIColor(red: 0.2, green: 0.0, blue: 0.5, alpha: 1).cgColor
              ]
            : [
                UIColor.white.cgColor,
                UIColor(white: 0.9, alpha: 1).cgColor
              ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer
    }

    var uiKitTextColor: UIColor {
        return isDarkMode ? .white : .black
    }

    var uiKitSecondaryTextColor: UIColor {
        return isDarkMode ? .gray : .black.withAlphaComponent(0.7)
    }

    var uiKitButtonGradient: CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = isDarkMode
            ? [
                UIColor.blue.cgColor,
                UIColor.purple.cgColor,
                UIColor(red: 1.0, green: 0.5, blue: 0.7, alpha: 1.0).cgColor
              ]
            : [
                UIColor.gray.cgColor,
                UIColor.gray.withAlphaComponent(0.8).cgColor
              ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer
    }

    func applyGradient(to view: UIView) {
        let gradientLayer = uiKitBackgroundGradient
        gradientLayer.frame = view.bounds
        if let existingGradient = view.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
            existingGradient.colors = gradientLayer.colors
        } else {
            view.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
}

extension Notification.Name {
    static let themeChanged = Notification.Name("themeChanged")
}
