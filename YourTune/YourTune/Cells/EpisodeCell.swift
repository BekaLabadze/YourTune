//
//  EpisodeCell.swift
//  YourTune
//
//  Created by Beka on 24.01.25.
//

import UIKit

class EpisodeCell: UICollectionViewCell {
    static let reuseIdentifier = "EpisodeCell"

    var episodeTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    var episodeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        episodeImageView.translatesAutoresizingMaskIntoConstraints = false
        episodeTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(episodeImageView)
        contentView.addSubview(episodeTitleLabel)

        NSLayoutConstraint.activate([
            episodeImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            episodeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            episodeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 20),
            episodeImageView.heightAnchor.constraint(equalToConstant: 250),
            episodeTitleLabel.topAnchor.constraint(equalTo: episodeImageView.bottomAnchor, constant: -20),
            episodeTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            episodeTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 15),
            episodeTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    func configure(episode: Episode, tvShowObject: TVShow) {
        episodeImageView.image = UIImage(named: tvShowObject.image)
        episodeTitleLabel.text = episode.title
        episodeTitleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        if ThemeManager.shared.isDarkMode {
            episodeTitleLabel.textColor = .white
        } else {
            episodeTitleLabel.textColor = .black
        }
    }
}
