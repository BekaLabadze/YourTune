//
//  SongsViewController.swift
//  YourTune
//
//  Created by Beka on 24.01.25.
//

import UIKit
import AVFoundation

class SongsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let songTable = UITableView()
    private var themeObserver: NSObjectProtocol?
    var songs: [Song]!
    var tvShowObject: TVShow!
    var userViewModel: UserViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupThemeObserver()
        fetchAndMapSongs()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyTheme()
    }

    
    private func configureUI() {
        songTable.delegate = self
        songTable.dataSource = self
        songTable.register(SongsCell.self, forCellReuseIdentifier: "SongsCell")
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

    private func fetchAndMapSongs() {
        songs.forEach { song in
            DeezerAPI().fetchSongDetails(songName: song.title) { [weak self] result in
                guard let self = self else { return }
                if case .success(let fetchedSong) = result {
                    self.updateSongArray(with: fetchedSong)
                }
            }
        }
    }

    private func updateSongArray(with deezer: Deezer) {
        if let index = songs.firstIndex(where: { $0.title == deezer.title || $0.artist == deezer.artist.name }) {
            songs[index].preview = deezer.preview
            songs[index].album = deezer.album
            DispatchQueue.main.async {
                self.songTable.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        songs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SongsCell", for: indexPath) as? SongsCell else {
            return UITableViewCell()
        }
        let song = songs[indexPath.row]
        cell.configure(with: song, userViewModel: userViewModel, tvShowID: tvShowObject.id, episodeID: findEpisodeID(for: song) ?? "")
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedSong = songs[indexPath.row]
        guard let tvShowID = tvShowObject?.id, let episodeID = findEpisodeID(for: selectedSong) else { return }
        incrementViewCount(for: selectedSong, in: episodeID, of: tvShowID)
        let playerVC = Player()
        playerVC.songArray = songs
        playerVC.selectedSong = selectedSong
        playerVC.tvShowObject = tvShowObject
        navigationController?.pushViewController(playerVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }

    private func incrementViewCount(for song: Song, in episodeID: String, of tvShowID: String) {
        userViewModel.incrementViewCount(for: song, in: episodeID, of: tvShowID)
    }

    private func findEpisodeID(for song: Song) -> String? {
        tvShowObject.seasons.flatMap { $0.episodes }.first { $0.Songs.contains { $0.id == song.id } }?.id
    }

    deinit {
        if let observer = themeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
