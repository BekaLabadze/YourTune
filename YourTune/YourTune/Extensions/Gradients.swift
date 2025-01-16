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
        static let shinyDarkGradient = LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.05, green: 0.05, blue: 0.2),
                Color(red: 0.1, green: 0.0, blue: 0.3),
                Color(red: 0.2, green: 0.0, blue: 0.5)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    
    static let visibleShinyDark = LinearGradient(
        gradient: Gradient(colors: [.blue, .purple, .pink]),
        startPoint: .leading,
        endPoint: .trailing
    )
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
