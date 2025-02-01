//
//  ErrorViewController.swift
//  YourTune
//
//  Created by Beka on 01.02.25.
//

import UIKit

class ErrorViewController: UIViewController {
    var song: Song?
    
    let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Sorry, fetching song failed."
        label.textColor = ThemeManager.shared.isDarkMode ? .white : .black
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    let youtubeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Watch on YouTube", for: .normal)
        button.setTitleColor(ThemeManager.shared.isDarkMode ? .black : .white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = ThemeManager.shared.isDarkMode ? UIColor(red: 0.12, green: 0.73, blue: 0.33, alpha: 1.0) : UIColor(red: 0.12, green: 0.73, blue: 0.33, alpha: 1.0)
        button.layer.cornerRadius = 10
        return button
    }()
    
    init(song: Song?) {
        self.song = song
        super.init(nibName: nil, bundle: nil)
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = ThemeManager.shared.isDarkMode ? UIColor.black : UIColor.white
        applyTheme()
        view.addSubview(errorLabel)
        view.addSubview(youtubeButton)
        
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            youtubeButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 20),
            youtubeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            youtubeButton.heightAnchor.constraint(equalToConstant: 50),
            youtubeButton.widthAnchor.constraint(equalToConstant: 200)
        ])
        youtubeButton.addTarget(self, action: #selector(openYouTube), for: .touchUpInside)
    }
    
    @objc func openYouTube() {
            guard let song = song, let youtubeURL = URL(string: song.localAudioname) else { return }
            UIApplication.shared.open(youtubeURL, options: [:], completionHandler: nil)
        }
    
    private func applyTheme() {
        let isDarkMode = ThemeManager.shared.isDarkMode

        view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        if isDarkMode {
            let gradientLayer = ThemeManager.shared.uiKitBackgroundGradient
            gradientLayer.frame = view.bounds
            view.layer.insertSublayer(gradientLayer, at: 0)
            view.backgroundColor = .clear
        } else {
            view.backgroundColor = .adjustedWhite
            view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        }
    }
}
