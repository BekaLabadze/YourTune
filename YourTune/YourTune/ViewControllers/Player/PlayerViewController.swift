//
//  PlayerViewController.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import UIKit

class PlayerViewController: UIViewController {
    
    var viewModel: PlayerViewModel
    
    var dismissAction: (() -> Void)?
    var isFromSwiftUI: Bool = false
    
    init(
        viewModel: PlayerViewModel,
        dismissAction: (() -> Void)? = nil,
        isFromSwiftUI: Bool
    ) {
        self.viewModel = viewModel
        self.dismissAction = dismissAction
        self.isFromSwiftUI = isFromSwiftUI
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let playButton: UIButton = {
        let button = UIButton()
        button.setSymbolImage(systemName: "play.fill", pointSize: 40, weight: .bold)
        button.tintColor = .purple
        return button
    }()

    let nextButton: UIButton = {
        let button = UIButton()
        button.setSymbolImage(systemName: "forward.fill", pointSize: 20, weight: .bold)
        button.tintColor = .purple
        return button
    }()

    let backButton: UIButton = {
        let button = UIButton()
        button.setSymbolImage(systemName: "backward.fill", pointSize: 20, weight: .bold)
        button.tintColor = .purple
        return button
    }()
    
    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Dismiss", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let addToPlayList: UIButton = {
        let button = UIButton()
        button.setSymbolImage(systemName: "plus.circle.fill", pointSize: 20, weight: .bold)
        button.tintColor = .purple
        return button
    }()
    
    let trimButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Trim", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .purple
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
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
        slider.tintColor = .purple
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
        if isFromSwiftUI {
            setupDismissButton()
        }
        loadInitialSong()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopObservingProgress()
    }

    private func setUpUI() {
        let backgroundImageView = UIImageView()
        if let albumCoverURL = viewModel.selectedSong.album?.cover {
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
            gradientLayer.frame = UIScreen.main.bounds

            let gradientView = UIView()
            gradientView.layer.addSublayer(gradientLayer)
            gradientView.translatesAutoresizingMaskIntoConstraints = false
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
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        view.sendSubviewToBack(gradientView)
        view.sendSubviewToBack(blurEffectView)
        view.sendSubviewToBack(backgroundImageView)
        setupForegroundUI()
    }

    private func setupDismissButton() {
        view.addSubview(dismissButton)
        
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            dismissButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            dismissButton.heightAnchor.constraint(equalToConstant: 40),
            dismissButton.widthAnchor.constraint(equalToConstant: 100),
        ])
        
        dismissButton.addTarget(self, action: #selector(dismissPlayer), for: .touchUpInside)
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
        view.addSubview(trimButton)
        
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

                trimButton.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 20),
                trimButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                trimButton.heightAnchor.constraint(equalToConstant: 50),
                trimButton.widthAnchor.constraint(equalToConstant: 100),

                progressBar.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 20),
                progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
                progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
                progressBar.heightAnchor.constraint(equalToConstant: 30),

                currentTimeLabel.leadingAnchor.constraint(equalTo: progressBar.leadingAnchor),
                currentTimeLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 5),
                currentTimeLabel.widthAnchor.constraint(equalToConstant: 50),

                durationLabel.trailingAnchor.constraint(equalTo: progressBar.trailingAnchor),
                durationLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 5),
                durationLabel.widthAnchor.constraint(equalToConstant: 50),
                
            ])
                    
                    playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
                    nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
                    backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
                    progressBar.addTarget(self, action: #selector(didChangeProgress(_:)), for: .valueChanged)
                    addToPlayList.addTarget(self, action: #selector(addToPlayListTapped), for: .touchUpInside)
                    trimButton.addTarget(self, action: #selector(trimButtonTapped), for: .touchUpInside)
        
                }
    
    @objc private func trimButtonTapped(sender: UIButton) {
        switch viewModel.trimState {
        case .started:
            sender.setTitle("Stop Trim", for: .normal)
        case .ended:
            sender.setTitle("Trim", for: .normal)
        case .initial:
            sender.setTitle("Start Trim", for: .normal)
        }
        
        viewModel.setTrimState { [weak self] result in
            self?.handleDownloadedFile(result: result)
        }
    }
    
    func handleDownloadedFile(result: Result<URL, Error>) {
        DispatchQueue.main.async {
            switch result {
            case .success(let fileURL):
                print("Audio downloaded and reprocessed successfully to: \(fileURL.path)")
                self.saveToFiles(fileURL: fileURL)
            case .failure(let error):
                print("Failed to download or reprocess audio: \(error.localizedDescription)")
                self.showDownloadErrorAlert(error: error)
            }
        }
    }

    
    func saveToFiles(fileURL: URL) {
        let documentPicker = UIDocumentPickerViewController(forExporting: [fileURL])
        documentPicker.modalPresentationStyle = .formSheet
        self.present(documentPicker, animated: true, completion: nil)
    }
    

    private func loadInitialSong() {
        viewModel.loadInitialSong()
        startObservingProcess()
        updateUIForCurrentSong()
        playButton.setSymbolImage(systemName: "pause.fill", pointSize: 40, weight: .bold)
    }
    
    private func startObservingProcess() {
        viewModel.startObservingProgress { [weak self] currentTime, normalizedCurrentTime in
            self?.setUpProgressBar(currentTime: Float(currentTime), normalizedCurrentTime: Float(normalizedCurrentTime))
        }
    }
    

    private func updateUIForCurrentSong() {
        songTitle.text = "\(viewModel.selectedSong.title) by \(viewModel.selectedSong.artist)"
        descriptionTitle.text = "Scene: \(viewModel.selectedSong.description)"
        songImage.setImage(from: viewModel.selectedSong.album?.cover)
        setUpProgressBar(currentTime: 0, normalizedCurrentTime: 0)
        playButton.setSymbolImage(systemName: "pause.fill", pointSize: 40, weight: .bold)
    }

    private func setUpProgressBar(currentTime: Float, normalizedCurrentTime: Float) {
        guard let duration = viewModel.getDuration() else { return }

        DispatchQueue.main.async {
            self.progressBar.value = normalizedCurrentTime
            self.durationLabel.text = self.formatTime(duration)
            self.currentTimeLabel.text = self.formatTime(currentTime)
        }
    }
   

    private func formatTime(_ time: Float) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    @objc private func dismissPlayer() {
            dismissAction?()
        }
    
    @objc private func playButtonTapped() {
        viewModel.playButtonTapped()
        setPlayerButtonImage()
    }

    @objc private func nextButtonTapped() {
        viewModel.nextButtonTapped()
    }

    @objc private func backButtonTapped() {
        viewModel.backButtonTapped()
    }

    private func prepareForNextSong() {
        viewModel.prepareForNextSong()
        updateUIForCurrentSong()
    }

    @objc private func didChangeProgress(_ sender: UISlider) {
        viewModel.didChangeProgress(value: sender.value)
    }

    @objc private func addToPlayListTapped() {
        let playlistVC = PlayListViewController(
            viewModel: .init(selectedSong: viewModel.selectedSong)
        )
        
        let navController = makeNavigationController(rootViewController: playlistVC)
        
        present(navController, animated: true)
    }
    
    private func makeNavigationController(rootViewController: UIViewController) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.modalPresentationStyle = .pageSheet
        navController.sheetPresentationController?.detents = [.medium(), .large()]
        navController.view.backgroundColor = .clear
        GradientHelper.applyShinyDarkGradient(to: navController.view)
        return navController
    }
    
    private func setPlayerButtonImage() {
        if viewModel.isPlaying {
            playButton.setSymbolImage(systemName: "pause.fill", pointSize: 40, weight: .bold)
        } else {
            playButton.setSymbolImage(systemName: "play.fill", pointSize: 40, weight: .bold)
        }
    }
}

extension PlayerViewController {
    private func showDownloadSuccessAlert(fileURL: URL) {
        let alert = UIAlertController(title: "Download Complete", message: "The audio file was downloaded and reprocessed successfully to \(fileURL.path). You can now open it on your Mac.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showDownloadErrorAlert(error: Error) {
        let alert = UIAlertController(title: "Download Failed", message: "An error occurred: \(error.localizedDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
