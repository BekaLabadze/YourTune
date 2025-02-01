//
//  SeasonCell.swift
//  YourTune
//
//  Created by Beka on 24.01.25.
//

import UIKit

class SeasonCell: UITableViewCell {
    private let seasonLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let seasonIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "tv")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        if ThemeManager.shared.isDarkMode {
            contentView.backgroundColor = .black
            setupUI()
        } else {
            setupCellStyle()
            setupUI()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCellStyle() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear

        layer.cornerRadius = 12
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 5

        let gradientLayer = ThemeManager.shared.uiKitCellGradient
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = 12

        if let oldGradient = contentView.layer.sublayers?.first(where: { $0 is CAGradientLayer }) {
            oldGradient.removeFromSuperlayer()
        }

        contentView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupUI() {
        contentView.addSubview(seasonIcon)
        contentView.addSubview(seasonLabel)

        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: 80),

            seasonIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            seasonIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            seasonIcon.widthAnchor.constraint(equalToConstant: 30),
            seasonIcon.heightAnchor.constraint(equalToConstant: 30),

            seasonLabel.leadingAnchor.constraint(equalTo: seasonIcon.trailingAnchor, constant: 12),
            seasonLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            seasonLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if ThemeManager.shared.isDarkMode {
            applyTheme()
        } else {
            setupCellStyle()
        }
    }

    private func applyTheme() {
        let isDarkMode = ThemeManager.shared.isDarkMode

        contentView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        if isDarkMode {
            let gradientLayer = ThemeManager.shared.uiKitBackgroundGradient
            gradientLayer.frame = contentView.bounds
            contentView.layer.insertSublayer(gradientLayer, at: 0)
            contentView.backgroundColor = .clear
        } else {
            contentView.backgroundColor = .lightGray
            contentView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        }
    }
    
    func configure(_ tvShowObject: TVShow, _ season: Season) {
        seasonLabel.text = "Season \(season.seasonNumber)"
        if ThemeManager.shared.isDarkMode {
            applyTheme()
        } else {
            seasonLabel.textColor = .black
        }
    }
}
