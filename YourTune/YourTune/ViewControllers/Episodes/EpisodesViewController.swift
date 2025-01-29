//
//  EpisodesViewController.swift
//  YourTune
//
//  Created by Beka on 24.01.25.
//

import UIKit

class EpisodesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var viewModel: EpisodesViewModel
    var userViewModel: UserViewModel?
    var episodeCollectionView: UICollectionView?
    private var themeObserver: NSObjectProtocol?
    
    init(viewModel: EpisodesViewModel, userViewModel: UserViewModel? = nil) {
        self.viewModel = viewModel
        self.userViewModel = userViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        setupCollectionView()
        guard let episodeCollectionView else { return }
        view.addSubview(episodeCollectionView)
        setupCollectionViewConstraints()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 20
        layout.itemSize = CGSize(width: (view.frame.width - 30) / 2, height: 150)
        
        episodeCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        guard let episodeCollectionView else { return }
        episodeCollectionView.translatesAutoresizingMaskIntoConstraints = false
        episodeCollectionView.delegate = self
        episodeCollectionView.dataSource = self
        episodeCollectionView.register(EpisodeCell.self, forCellWithReuseIdentifier: EpisodeCell.reuseIdentifier)
        episodeCollectionView.backgroundColor = .clear
    }
    
    private func setupCollectionViewConstraints() {
        guard let episodeCollectionView else { return }
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
            episodeCollectionView?.backgroundColor = .clear
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
        return viewModel.season.episodes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EpisodeCell.reuseIdentifier, for: indexPath) as! EpisodeCell
        let episode = viewModel.getEpisode(index: indexPath.row)
        cell.configure(episode: episode, tvShowObject: viewModel.tvShowObject)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width - 30) / 2, height: 320)

    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let songsVC = SongsViewController(
            viewModel: .init(
                songs: viewModel.season.episodes[indexPath.row].Songs,
                tvShowObject: viewModel.tvShowObject,
                userViewModel: userViewModel!
            )
        )
        navigationController?.pushViewController(songsVC, animated: true)
    }

    deinit {
        if let observer = themeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
