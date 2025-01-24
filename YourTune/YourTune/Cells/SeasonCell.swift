//
//  SeasonCell.swift
//  YourTune
//
//  Created by Beka on 24.01.25.
//

import UIKit

class SeasonCell: UITableViewCell {
    var seasonLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.text = ""
        label.textColor = .purple
        return label
    }()
    
    var seasonImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        seasonLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(seasonImage)
        contentView.addSubview(seasonLabel)
        
        
        seasonLabel.applyGradientText(with: .shinyDark)

        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: 250),
            seasonLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            seasonLabel.topAnchor.constraint(equalTo: seasonImage.bottomAnchor),
            seasonLabel.heightAnchor.constraint(equalToConstant: 30),
            
            seasonImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            seasonImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            seasonImage.widthAnchor.constraint(equalToConstant: 300),
            seasonImage.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        GradientHelper.applyShinyDarkGradient(to: contentView)
    }
    
    func configure(_ tvShowObject: TVShow, _ season: Season) {
        seasonLabel.text = ("Season: \(season.seasonNumber)")
        if ThemeManager.shared.isDarkMode {
            seasonLabel.textColor = .white
        } else {
            seasonLabel.textColor = .black
        }
        seasonImage.image = UIImage(named: tvShowObject.image)
    }
}
