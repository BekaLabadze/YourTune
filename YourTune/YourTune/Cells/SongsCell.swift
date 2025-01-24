//
//  SongsCell.swift
//  YourTune
//
//  Created by Beka on 24.01.25.
//

import UIKit

class SongsCell: UITableViewCell {
    var playerManager: PlayerManager = PlayerManager()
    var song: Song?
    var userViewModel: UserViewModel?
    var tvShowID: String?
    var episodeID: String?

    let songTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 0
        return label
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
        return label
    }()

    let sceneDescription: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
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
        setupUI()
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

        albumCover.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        songTitle.translatesAutoresizingMaskIntoConstraints = false
        songArtist.translatesAutoresizingMaskIntoConstraints = false
        sceneDescription.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            albumCover.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            albumCover.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            albumCover.heightAnchor.constraint(equalToConstant: 60),
            albumCover.widthAnchor.constraint(equalToConstant: 60),
            
            songTitle.leadingAnchor.constraint(equalTo: albumCover.trailingAnchor, constant: 20),
            songTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            songTitle.heightAnchor.constraint(equalToConstant: 30),

            sceneDescription.leadingAnchor.constraint(equalTo: songTitle.leadingAnchor),
            sceneDescription.topAnchor.constraint(equalTo: songTitle.bottomAnchor, constant: 20),
            sceneDescription.heightAnchor.constraint(equalToConstant: 30),
            
            songArtist.leadingAnchor.constraint(equalTo: songTitle.leadingAnchor),
            songArtist.topAnchor.constraint(equalTo: songTitle.bottomAnchor, constant: -5),
            songArtist.heightAnchor.constraint(equalToConstant: 30),

            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            favoriteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            playButton.leadingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -30),
            playButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])

        playButton.addTarget(self, action: #selector(checkAudio), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
    }

    func configure(with song: Song, userViewModel: UserViewModel?, tvShowID: String, episodeID: String) {
        self.song = song
        self.userViewModel = userViewModel
        self.tvShowID = tvShowID
        self.episodeID = episodeID

        albumCover.setImage(from: song.album?.cover, placeholder: UIImage(systemName: "music"))
        albumCover.layer.cornerRadius = 15
        albumCover.clipsToBounds = true
        songTitle.text = song.title
        songArtist.text = song.artist
        sceneDescription.text = song.description
        
        if ThemeManager.shared.isDarkMode {
            songTitle.textColor = .white
            songArtist.textColor = .white
            sceneDescription.textColor = .white
        } else {
            songTitle.textColor = .black
            songArtist.textColor = .black
            sceneDescription.textColor = .black
        }
        
        if let previewURL = song.preview {
            playerManager.initPlayer(with: previewURL)
        } else {
            print("Preview URL is nil. Cannot initialize player.")
        }

        updateFavoriteButtonState()
    }

    func updateFavoriteButtonState() {
        guard let userViewModel = userViewModel, let song = song else { return }
        let isFavorited = userViewModel.isFavorite(song)
        DispatchQueue.main.async {
            self.favoriteButton.setImage(
                UIImage(systemName: isFavorited ? "heart.fill" : "heart"),
                for: .normal
            )
        }
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
        GradientHelper.applyShinyDarkGradient(to: contentView)
    }

    @objc func toggleFavorite() {
        guard let userViewModel = userViewModel,
              let song = song,
              let tvShowID = tvShowID,
              let episodeID = episodeID else { return }

        let isCurrentlyFavorited = userViewModel.isFavorite(song)
        favoriteButton.setImage(
            UIImage(systemName: isCurrentlyFavorited ? "heart" : "heart.fill"),
            for: .normal
        )

        userViewModel.toggleFavorite(for: song, in: episodeID, of: tvShowID)
    }

}
