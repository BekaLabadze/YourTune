//
//  EpisodeCell.swift
//  YourTune
//
//  Created by Beka on 24.01.25.
//

import UIKit

class EpisodeCell: UICollectionViewCell {
    static let reuseIdentifier = "EpisodeCell"
    var isFirstColumn: Bool = false
    private var leadingConstraint: NSLayoutConstraint?
    private var leadingTitle: NSLayoutConstraint?

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
    
    var shadowContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        view.layer.shadowColor = UIColor.white.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 6
        view.layer.cornerRadius = 8
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
        func setupUI() {
            shadowContainer.translatesAutoresizingMaskIntoConstraints = false
            episodeImageView.translatesAutoresizingMaskIntoConstraints = false
            episodeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.addSubview(shadowContainer)
            shadowContainer.addSubview(episodeImageView)
            contentView.addSubview(episodeTitleLabel)
            
            NSLayoutConstraint.activate([
                shadowContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
                shadowContainer.heightAnchor.constraint(equalToConstant: 250),
                shadowContainer.widthAnchor.constraint(equalToConstant: 180),
                
                episodeImageView.topAnchor.constraint(equalTo: shadowContainer.topAnchor),
                episodeImageView.leadingAnchor.constraint(equalTo: shadowContainer.leadingAnchor),
                episodeImageView.trailingAnchor.constraint(equalTo: shadowContainer.trailingAnchor),
                episodeImageView.bottomAnchor.constraint(equalTo: shadowContainer.bottomAnchor),
                
                episodeTitleLabel.topAnchor.constraint(equalTo: shadowContainer.bottomAnchor, constant: 8),
                episodeTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
                episodeTitleLabel.leadingAnchor.constraint(equalTo: shadowContainer.leadingAnchor, constant: 20),
                episodeTitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
            ])
            
            leadingConstraint = shadowContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0)
            leadingConstraint?.isActive = true
            leadingTitle = episodeTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0)
            leadingTitle?.isActive = true

        }
        
        
        func configure(episode: Episode, tvShowObject: TVShow, isFirstColumn: Bool) {
            episodeTitleLabel.text = episode.title
            episodeTitleLabel.font = .systemFont(ofSize: 15, weight: .medium)
            episodeTitleLabel.textColor = ThemeManager.shared.isDarkMode ? .white : .black
            leadingConstraint?.constant = isFirstColumn ? 20 : 0
            leadingTitle?.constant = isFirstColumn ? 55 : 20
        
        
            if let imageURL = URL(string: tvShowObject.image) {
                loadImage(from: imageURL)
            } else {
                episodeImageView.image = UIImage(systemName: "photo")
            }
        }
    
        private func loadImage(from url: URL) {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.episodeImageView.image = image
                    }
                } else {
                    DispatchQueue.main.async {
                        self.episodeImageView.image = UIImage(systemName: "photo")
                    }
                }
            }.resume()
        }
}
