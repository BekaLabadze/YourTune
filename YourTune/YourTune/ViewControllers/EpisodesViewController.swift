//
//  EpisodesViewController.swift
//  YourTune
//
//  Created by Beka on 24.01.25.
//

import UIKit

class EpisodesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var viewModel: TVShowViewModel?
    var season: Season!
    var tvShowObject: TVShow!
    var userViewModel: UserViewModel?
    var episodeCollectionView: UICollectionView!
    private var themeObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupThemeObserver()
        applyTheme()
        applyNavigationBarAppearance()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyTheme()
        applyNavigationBarAppearance()
    }

    private func configureUI() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 20
        layout.itemSize = CGSize(width: (view.frame.width - 30) / 2, height: 150)

        episodeCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        episodeCollectionView.translatesAutoresizingMaskIntoConstraints = false
        episodeCollectionView.delegate = self
        episodeCollectionView.dataSource = self
        episodeCollectionView.register(EpisodeCell.self, forCellWithReuseIdentifier: EpisodeCell.reuseIdentifier)
        episodeCollectionView.backgroundColor = .clear

        view.addSubview(episodeCollectionView)

        NSLayoutConstraint.activate([
            episodeCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            episodeCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            episodeCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            episodeCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupThemeObserver() {
        themeObserver = NotificationCenter.default.addObserver(
            forName: .themeChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applyTheme()
            self?.applyNavigationBarAppearance()
        }
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
            view.backgroundColor = .white
            episodeCollectionView.backgroundColor = .clear
            view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        }
    }

    private func applyNavigationBarAppearance() {
        let isDarkMode = ThemeManager.shared.isDarkMode
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = isDarkMode ? .clear : .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return season.episodes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EpisodeCell.reuseIdentifier, for: indexPath) as! EpisodeCell
        let episode = season.episodes[indexPath.row]
        cell.configure(episode: episode, tvShowObject: tvShowObject)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width - 30) / 2, height: 320)

    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let songsVC = SongsViewController()
        songsVC.songs = season.episodes[indexPath.row].Songs
        songsVC.tvShowObject = tvShowObject
        songsVC.userViewModel = userViewModel
        navigationController?.pushViewController(songsVC, animated: true)
    }

    deinit {
        if let observer = themeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
