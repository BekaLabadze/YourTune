//
//  SongsViewController.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import UIKit
import AVFoundation

class SongsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var viewModel: SongsViewModel
    private let songTable = UITableView()
    private var themeObserver: NSObjectProtocol?
    
    init(viewModel: SongsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupThemeObserver()
        fetchSongs()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyTheme()
    }

    
    private func configureUI() {
        setupTableView()
        setupTableViewConstraints()
    }
    
    private func setupTableView() {
        songTable.delegate = self
        songTable.dataSource = self
        songTable.register(SongsCell.self, forCellReuseIdentifier: "SongsCell")
    }
    
    private func setupTableViewConstraints() {
        songTable.backgroundColor = .clear
        songTable.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(songTable)
        NSLayoutConstraint.activate([
            songTable.topAnchor.constraint(equalTo: view.topAnchor),
            songTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            songTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            songTable.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupThemeObserver() {
        themeObserver = NotificationCenter.default.addObserver(
            forName: .themeChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applyTheme()
        }
    }

    private func applyTheme() {
        view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        if ThemeManager.shared.isDarkMode {
            let gradientLayer = ThemeManager.shared.uiKitBackgroundGradient
            gradientLayer.frame = view.bounds
            view.layer.insertSublayer(gradientLayer, at: 0)
            view.backgroundColor = .clear
        } else {
            view.backgroundColor = .white
            songTable.backgroundColor = .clear
            view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.songsCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SongsCell", for: indexPath) as? SongsCell else {
            return UITableViewCell()
        }
        let song = viewModel.getSong(at: indexPath.row)
        cell.configure(
            with: song,
            userViewModel: viewModel.userViewModel,
            tvShowID: viewModel.tvShowObject.id,
            episodeID: viewModel.findEpisodeID(for: song) ?? ""
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedSong = viewModel.getSong(at: indexPath.row)
        let tvShowID = viewModel.tvShowObject.id
        guard let episodeID = viewModel.findEpisodeID(for: selectedSong) else { return }
        viewModel.incrementViewCount(for: selectedSong, in: episodeID, of: tvShowID)
        let playerViewModel = PlayerViewModel(
            songArray: viewModel.songs,
            selectedSong: selectedSong
        )
        let playerVC = PlayerViewController(
            viewModel: playerViewModel,
            isFromSwiftUI: false
        )
        navigationController?.pushViewController(playerVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }

    

    deinit {
        if let observer = themeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func fetchSongs() {
        viewModel.fetchAndMapSongs() { [weak self] in
            self?.songTable.reloadData()
        }
    }
}
