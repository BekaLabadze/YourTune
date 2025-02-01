//
//  SongsCell.swift
//  YourTune
//
//  Created by Beka on 24.01.25.
//

import UIKit

protocol SongCellDelegate: NSObjectProtocol {
    func updateFavorites()
}

class SongsCell: UITableViewCell {
    var playerManager: PlayerManager = PlayerManager()
    var song: Song?
    var tvShowID: String?
    var episodeID: String?
    var checkDeezer: DeezerAPI?
    weak var delegate: SongCellDelegate?
    
    let songTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = false
        return label
    }()

    let youtubeButton: UIButton = {
            let button = UIButton()
            button.setImage(UIImage(systemName: "globe"), for: .normal)
            button.tintColor = .red
            return button
        }()
    
    let albumCover: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 15
        image.mask?.clipsToBounds = true
        return image
    }()
    
    let songArtist: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = false
        return label
    }()

    let sceneDescription: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = false
        return label
    }()
    
    let playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play"), for: .normal)
        return button
    }()

    let favoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .red
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        if ThemeManager.shared.isDarkMode {
            setupUI()
        } else {
            setupCellStyle()
            setupUI()
        }
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        contentView.addSubview(songTitle)
        contentView.addSubview(songArtist)
        contentView.addSubview(playButton)
        contentView.addSubview(favoriteButton)
        contentView.addSubview(albumCover)
        contentView.addSubview(sceneDescription)
        contentView.addSubview(youtubeButton)
        
        albumCover.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        songTitle.translatesAutoresizingMaskIntoConstraints = false
        songArtist.translatesAutoresizingMaskIntoConstraints = false
        sceneDescription.translatesAutoresizingMaskIntoConstraints = false
        youtubeButton.translatesAutoresizingMaskIntoConstraints = false

        songTitle.setContentHuggingPriority(.defaultHigh, for: .vertical)
                songArtist.setContentHuggingPriority(.defaultHigh, for: .vertical)
                sceneDescription.setContentHuggingPriority(.defaultHigh, for: .vertical)

                songTitle.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
                songArtist.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
                sceneDescription.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        
        NSLayoutConstraint.activate([
            albumCover.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            albumCover.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            albumCover.widthAnchor.constraint(equalToConstant: 60),
            albumCover.heightAnchor.constraint(equalToConstant: 60),

            songTitle.leadingAnchor.constraint(equalTo: albumCover.trailingAnchor, constant: 12),
            songTitle.trailingAnchor.constraint(equalTo: youtubeButton.leadingAnchor, constant: -10),
            songTitle.topAnchor.constraint(equalTo: albumCover.topAnchor),
            
            songArtist.leadingAnchor.constraint(equalTo: songTitle.leadingAnchor),
            songArtist.trailingAnchor.constraint(equalTo: youtubeButton.leadingAnchor, constant: -10),
            songArtist.topAnchor.constraint(equalTo: songTitle.bottomAnchor, constant: 5),
            
            sceneDescription.leadingAnchor.constraint(equalTo: songTitle.leadingAnchor),
            sceneDescription.trailingAnchor.constraint(equalTo: youtubeButton.leadingAnchor, constant: -10),
            sceneDescription.topAnchor.constraint(equalTo: songArtist.bottomAnchor, constant: 5),
            sceneDescription.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -15),

            youtubeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            youtubeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            youtubeButton.widthAnchor.constraint(equalToConstant: 30),
            youtubeButton.heightAnchor.constraint(equalToConstant: 30),

            favoriteButton.trailingAnchor.constraint(equalTo: youtubeButton.leadingAnchor, constant: 5),
            favoriteButton.centerYAnchor.constraint(equalTo: youtubeButton.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 30),
            favoriteButton.heightAnchor.constraint(equalToConstant: 30),

            playButton.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: 5),
            playButton.centerYAnchor.constraint(equalTo: favoriteButton.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 30),
            playButton.heightAnchor.constraint(equalToConstant: 30),
        ])


        playButton.addTarget(self, action: #selector(checkAudio), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
        youtubeButton.addTarget(self, action: #selector(openYouTube), for: .touchUpInside)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        playerManager.stopAudio()
        songTitle.text = nil
        songArtist.text = nil
        sceneDescription.text = nil
        albumCover.image = nil
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
    
    func configure(with song: Song, tvShowID: String, episodeID: String, delegate: SongCellDelegate) {
        self.song = song
        self.tvShowID = tvShowID
        self.episodeID = episodeID
        self.delegate = delegate
        songTitle.text = song.title
        songArtist.text = song.artist
        sceneDescription.text = song.description

        albumCover.image = nil
        if let albumCoverURL = song.album?.cover {
            albumCover.setImage(from: albumCoverURL, placeholder: UIImage(systemName: "music.note"))
        } else {
            albumCover.image = UIImage(systemName: "music.note")
        }

        albumCover.layer.cornerRadius = 15
        albumCover.clipsToBounds = true

        songTitle.textColor = ThemeManager.shared.isDarkMode ? .white : .black
        songArtist.textColor = ThemeManager.shared.isDarkMode ? .white : .black
        sceneDescription.textColor = ThemeManager.shared.isDarkMode ? .white : .black

        playerManager.stopAudio()
        
        if let previewURL = song.preview, !previewURL.absoluteString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            playerManager.initPlayer(with: previewURL)
        } else {
            print("Error")
        }


        updateFavoriteButtonState()
    }

    func updateFavoriteButtonState() {
        guard let song = song else { return }
        let isFavorited = SessionProvider.shared.isFavorite(song)
        DispatchQueue.main.async {
            self.favoriteButton.setImage(
                UIImage(systemName: isFavorited ? "heart.fill" : "heart"),
                for: .normal
            )
        }
    }

    @objc func openYouTube() {
            guard let song = song, let youtubeURL = URL(string: song.localAudioname) else { return }
            UIApplication.shared.open(youtubeURL, options: [:], completionHandler: nil)
        }
    
    @objc func checkAudio() {
        if playerManager.isPlaying {
            playerManager.stopAudio()
            playButton.setImage(UIImage(systemName: "play"), for: .normal)
        } else {
            playerManager.playAudio()
            playButton.setImage(UIImage(systemName: "pause"), for: .normal)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if ThemeManager.shared.isDarkMode {
            GradientHelper.applyShinyDarkGradient(to: contentView)
        } else {
            setupCellStyle()
        }
    }

    @objc func toggleFavorite() {
        guard let song = song,
              let tvShowID = tvShowID,
              let episodeID = episodeID else { return }

        let isCurrentlyFavorited = SessionProvider.shared.isFavorite(song)
        favoriteButton.setImage(
            UIImage(systemName: isCurrentlyFavorited ? "plus.circle" : "plus.circle"),
            for: .normal
        )
        SessionProvider.shared.toggleFavorite(for: song, in: episodeID, of: tvShowID)
        delegate?.updateFavorites()
    }
}
