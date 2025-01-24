//
//  Gradients.swift
//  YourTune
//
//  Created by Beka on 13.01.25.
//

import UIKit
import SwiftUI

extension UIButton {
    func setSymbolImage(
        systemName: String,
        pointSize: CGFloat,
        weight: UIImage.SymbolWeight = .regular,
        tintColor: UIColor? = nil
    ) {
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
        let image = UIImage(systemName: systemName, withConfiguration: config)
        self.setImage(image, for: .normal)
        if let tintColor = tintColor {
            self.tintColor = tintColor
        }
    }
}

extension LinearGradient {
    static func shinyDarkGradient(isDarkMode: Bool) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: isDarkMode
                ? [
                    Color(red: 0.05, green: 0.05, blue: 0.2),
                    Color(red: 0.1, green: 0.0, blue: 0.3),
                    Color(red: 0.2, green: 0.0, blue: 0.5)
                ]
                : [
                    Color(red: 0.9, green: 0.9, blue: 1.0),
                    Color(red: 0.8, green: 0.8, blue: 1.0),
                    Color(red: 0.7, green: 0.7, blue: 1.0)
                ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func visibleShinyDark(isDarkMode: Bool) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: isDarkMode
                ? [.blue, .purple, .pink]
                : [.cyan, .teal, .orange]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

extension Color {
    static let shinySemiDark = Color(red: 0.3, green: 0.4, blue: 0.5)
}

extension UILabel {
    enum GradientStyle {
        case shinyDark

        var colors: [UIColor] {
            switch self {
            case .shinyDark:
                return [
                    UIColor(red: 20/255, green: 20/255, blue: 40/255, alpha: 1.0),
                    UIColor(red: 40/255, green: 30/255, blue: 60/255, alpha: 1.0),
                    UIColor(red: 60/255, green: 40/255, blue: 80/255, alpha: 1.0)
                ]
            }
        }
    }

    func applyGradientText(with style: GradientStyle, startPoint: CGPoint = CGPoint(x: 0, y: 0), endPoint: CGPoint = CGPoint(x: 1, y: 1)) {
        guard let text = self.text, !text.isEmpty else { return }
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = style.colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = self.bounds
        let textLayer = CATextLayer()
        textLayer.string = text
        textLayer.font = self.font
        textLayer.fontSize = self.font.pointSize
        textLayer.frame = self.bounds
        textLayer.alignmentMode = .center
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.foregroundColor = UIColor.black.cgColor
        gradientLayer.mask = textLayer
        self.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        self.layer.addSublayer(gradientLayer)
    }
}

extension UIImage {
    static func gradientImage(from gradient: LinearGradient) -> UIImage? {
        let controller = UIHostingController(rootView: gradient)
        let view = controller.view
        let size = CGSize(width: UIScreen.main.bounds.width, height: 88)
        view?.bounds = CGRect(origin: .zero, size: size)
        view?.backgroundColor = .clear
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            view?.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
        }
    }
}

extension UITableViewCell {
    func applyGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 20/255, green: 20/255, blue: 40/255, alpha: 1.0).cgColor,
            UIColor(red: 40/255, green: 30/255, blue: 60/255, alpha: 1.0).cgColor,
            UIColor(red: 60/255, green: 40/255, blue: 80/255, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = contentView.bounds
        contentView.layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension UISearchBar {
    static func applyGlobalGradientBackground() {
        let gradient = LinearGradient(
            gradient: Gradient(colors: [
                UIColor.systemPurple, UIColor.systemBlue, UIColor.systemTeal
            ].map { Color($0) }),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        let gradientImage = UIImage.fromLinearGradient(gradient, size: CGSize(width: UIScreen.main.bounds.width, height: 44))
        UISearchBar.appearance().backgroundImage = gradientImage
        UISearchBar.appearance().searchTextField.backgroundColor = .clear
        UISearchBar.appearance().searchTextField.textColor = .white
    }
}

extension UIImage {
    static func fromLinearGradient(_ gradient: LinearGradient, size: CGSize) -> UIImage? {
        let hostingController = UIHostingController(rootView: gradient)
        let view = hostingController.view
        view?.bounds = CGRect(origin: .zero, size: size)
        view?.backgroundColor = .clear
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            view?.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
        }
    }
}

extension UINavigationBarAppearance {
    static func gradientAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.05, green: 0.05, blue: 0.2, alpha: 1).cgColor,
            UIColor(red: 0.1, green: 0.0, blue: 0.3, alpha: 1).cgColor,
            UIColor(red: 0.2, green: 0.0, blue: 0.5, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 88)
        let gradientImage = UIGraphicsImageRenderer(size: gradientLayer.bounds.size).image { context in
            gradientLayer.render(in: context.cgContext)
        }
        appearance.backgroundImage = gradientImage
        appearance.shadowColor = .clear
        return appearance
    }
}

extension UIImageView {
    func setImage(from url: URL?, placeholder: UIImage? = nil) {
        DispatchQueue.main.async {
            self.image = placeholder
        }
        guard let url else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }.resume()
    }
}

class NavigationBarHelp {
    static func applyShinyDarkGradient(to navigationBar: UINavigationBar?) {
        guard let navigationBar = navigationBar else {
            return
        }
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 20/255, green: 20/255, blue: 40/255, alpha: 1.0).cgColor,
            UIColor(red: 40/255, green: 30/255, blue: 60/255, alpha: 1.0).cgColor,
            UIColor(red: 60/255, green: 40/255, blue: 80/255, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 88)
        let gradientView = UIView(frame: gradientLayer.frame)
        gradientView.layer.addSublayer(gradientLayer)
        let gradientImage = gradientView.asImage()
        appearance.backgroundImage = gradientImage
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.isTranslucent = true
    }
}

extension UIView {
    func asImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }
}

extension UITabBar {
    func applyShinyDarkGradient() {
        let gradientView = UIView(frame: bounds)
        GradientHelper.applyShinyDarkGradient(to: gradientView)
        backgroundImage = gradientView.asImage()
    }
}

extension Notification.Name {
    static let favoritesUpdated = Notification.Name("favoritesUpdated")
}
