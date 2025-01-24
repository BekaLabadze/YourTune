//
//  PlayerViewController.swift
//  YourTune
//
//  Created by Beka on 24.01.25.
//

import UIKit
import AVFoundation

class Player: UIViewController {
    var songArray: [Song]?
    var selectedSong: Song!
    var tvShowObject: TVShow!
    var audioPlayer: AVPlayer?
    var isPlaying: Bool = false
    var timeObserverToken: Any?

    let playButton: UIButton = {
        let button = UIButton()
        button.setSymbolImage(systemName: "play.fill", pointSize: 40, weight: .bold)
        return button
    }()

    let nextButton: UIButton = {
        let button = UIButton()
        button.setSymbolImage(systemName: "forward.fill", pointSize: 20, weight: .bold)
        return button
    }()

    let backButton: UIButton = {
        let button = UIButton()
        button.setSymbolImage(systemName: "backward.fill", pointSize: 20, weight: .bold)
        return button
    }()

    let addToPlayList: UIButton = {
        let button = UIButton()
        button.setSymbolImage(systemName: "plus.circle.fill", pointSize: 20, weight: .bold)
        return button
    }()

    let songImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 10
        image.layer.masksToBounds = true
        return image
    }()

    let songTitle: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()

    let descriptionTitle: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .bold)
        return label
    }()

    let progressBar: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.isContinuous = true
        return slider
    }()

    let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.text = "0:00"
        return label
    }()

    let durationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.text = "0:00"
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        loadInitialSong()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObservingProgress()
    }

    private func setUpUI() {
        let backgroundImageView = UIImageView()
        if let albumCoverURL = selectedSong.album?.cover {
            backgroundImageView.setImage(from: albumCoverURL)
        } else {
            backgroundImageView.image = UIImage(named: "placeholder")
        }
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImageView)
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurEffectView)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.8).cgColor, UIColor.clear.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        let gradientView = UIView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.layer.addSublayer(gradientLayer)
        view.addSubview(gradientView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.sendSubviewToBack(gradientView)
        view.sendSubviewToBack(blurEffectView)
        view.sendSubviewToBack(backgroundImageView)
        
        setupForegroundUI()
    }

    private func setupForegroundUI() {
        view.addSubview(playButton)
        view.addSubview(songImage)
        view.addSubview(progressBar)
        view.addSubview(nextButton)
        view.addSubview(backButton)
        view.addSubview(songTitle)
        view.addSubview(descriptionTitle)
        view.addSubview(currentTimeLabel)
        view.addSubview(durationLabel)
        view.addSubview(addToPlayList)

        playButton.translatesAutoresizingMaskIntoConstraints = false
        songImage.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        songTitle.translatesAutoresizingMaskIntoConstraints = false
        descriptionTitle.translatesAutoresizingMaskIntoConstraints = false
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        addToPlayList.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            songImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            songImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -150),
            songImage.heightAnchor.constraint(equalToConstant: 400),
            songImage.widthAnchor.constraint(equalToConstant: 400),

            songTitle.topAnchor.constraint(equalTo: songImage.bottomAnchor),
            songTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            songTitle.heightAnchor.constraint(equalToConstant: 50),
            songTitle.widthAnchor.constraint(equalToConstant: 200),

            descriptionTitle.topAnchor.constraint(equalTo: songTitle.bottomAnchor, constant: -20),
            descriptionTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionTitle.heightAnchor.constraint(equalToConstant: 50),
            descriptionTitle.widthAnchor.constraint(equalToConstant: 200),

            playButton.topAnchor.constraint(equalTo: songTitle.bottomAnchor, constant: 50),
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.heightAnchor.constraint(equalToConstant: 50),
            playButton.widthAnchor.constraint(equalToConstant: 100),

            backButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -10),
            backButton.topAnchor.constraint(equalTo: playButton.topAnchor),
            backButton.heightAnchor.constraint(equalToConstant: 50),
            backButton.widthAnchor.constraint(equalToConstant: 50),

            nextButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 10),
            nextButton.topAnchor.constraint(equalTo: playButton.topAnchor),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            nextButton.widthAnchor.constraint(equalToConstant: 50),

            addToPlayList.leadingAnchor.constraint(equalTo: nextButton.trailingAnchor, constant: 10),
            addToPlayList.topAnchor.constraint(equalTo: nextButton.topAnchor),
            addToPlayList.heightAnchor.constraint(equalToConstant: 50),
            addToPlayList.widthAnchor.constraint(equalToConstant: 50),

            progressBar.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 20),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            progressBar.heightAnchor.constraint(equalToConstant: 30),

            currentTimeLabel.leadingAnchor.constraint(equalTo: progressBar.leadingAnchor),
            currentTimeLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 5),
            currentTimeLabel.widthAnchor.constraint(equalToConstant: 50),

            durationLabel.trailingAnchor.constraint(equalTo: progressBar.trailingAnchor),
            durationLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 5),
            durationLabel.widthAnchor.constraint(equalToConstant: 50)
        ])
        
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        progressBar.addTarget(self, action: #selector(didChangeProgress(_:)), for: .valueChanged)
    }


    private func loadInitialSong() {
        guard let previewURL = selectedSong.preview else { return }
        initPlayer(with: previewURL)
        updateUIForCurrentSong()
        startObservingProgress()
        audioPlayer?.play()
        isPlaying = true
        playButton.setSymbolImage(systemName: "pause.fill", pointSize: 40, weight: .bold)
    }


    private func syncPlayButtonState() {
        if audioPlayer?.rate == 0 {
            playButton.setSymbolImage(systemName: "play.fill", pointSize: 40, weight: .bold)
            isPlaying = false
        } else {
            playButton.setSymbolImage(systemName: "pause.fill", pointSize: 40, weight: .bold)
            isPlaying = true
        }
    }

    private func initPlayer(with url: URL) {
        audioPlayer = AVPlayer(url: url)
        isPlaying = false
        syncPlayButtonState()
    }


    private func updateUIForCurrentSong() {
        songTitle.text = "\(selectedSong.title) by \(selectedSong.artist)"
        descriptionTitle.text = "Scene: \(selectedSong.description)"
        songImage.setImage(from: selectedSong.album?.cover)
        setUpProgressBar()
        playButton.setSymbolImage(systemName: "pause.fill", pointSize: 40, weight: .bold)
    }

    private func setUpProgressBar() {
        guard let player = audioPlayer,
              let currentItem = player.currentItem else { return }

        let duration = currentItem.duration.seconds
        guard duration.isFinite else { return }

        DispatchQueue.main.async {
            self.progressBar.maximumValue = Float(duration)
            self.progressBar.value = 0
            self.durationLabel.text = self.formatTime(duration)
            self.currentTimeLabel.text = self.formatTime(0)
        }
    }

    private func startObservingProgress() {
        guard let player = audioPlayer else { return }

        if let token = timeObserverToken {
            player.removeTimeObserver(token)
            timeObserverToken = nil
        }

        timeObserverToken = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] time in
            guard let self = self else { return }

            let currentTime = time.seconds
            let duration = player.currentItem?.duration.seconds ?? 0

            if duration.isFinite && duration > 0 {
                self.progressBar.maximumValue = Float(duration)
                self.durationLabel.text = self.formatTime(duration)
            }

            self.progressBar.value = Float(currentTime)
            self.currentTimeLabel.text = self.formatTime(currentTime)
        }
    }


    private func stopObservingProgress() {
        if let token = timeObserverToken {
            audioPlayer?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }

    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    @objc private func playButtonTapped() {
        if isPlaying {
            audioPlayer?.pause()
            isPlaying = false
            playButton.setSymbolImage(systemName: "play.fill", pointSize: 40, weight: .bold)
        } else {
            audioPlayer?.play()
            isPlaying = true
            playButton.setSymbolImage(systemName: "pause.fill", pointSize: 40, weight: .bold)
        }
    }

    @objc private func nextButtonTapped() {
        guard let currentIndex = songArray?.firstIndex(where: { $0.id == selectedSong.id }),
              currentIndex + 1 < songArray?.count ?? 0 else { return }
        selectedSong = songArray?[currentIndex + 1]
        prepareForNextSong()
    }

    @objc private func backButtonTapped() {
        guard let currentIndex = songArray?.firstIndex(where: { $0.id == selectedSong.id }),
              currentIndex - 1 >= 0 else { return }
        selectedSong = songArray?[currentIndex - 1]
        prepareForNextSong()
    }

    private func prepareForNextSong() {
        stopObservingProgress()
        if let previewURL = selectedSong.preview {
            initPlayer(with: previewURL)
        }
        updateUIForCurrentSong()
        startObservingProgress()
        audioPlayer?.play()
        isPlaying = true
    }

    @objc private func didChangeProgress(_ sender: UISlider) {
        guard let player = audioPlayer else { return }
        let newTime = CMTime(seconds: Double(sender.value), preferredTimescale: 1)
        player.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
}
