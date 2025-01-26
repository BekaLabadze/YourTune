//
//  PlayListViewController.swift
//  YourTune
//
//  Created by Beka on 26.01.25.
//

import UIKit

class PlayListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var playlists: [Playlist] = []
    var selectedSong: Song?

    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        GradientHelper.applyShinyDarkGradient(to: self.view)
        title = "Select Playlist"
        if ThemeManager.shared.isDarkMode {
            
        }
        GradientHelper.applyGradientBackground(to: tableView)
        setupTableView()
        loadPlaylists()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let sheet = self.navigationController?.sheetPresentationController {
            sheet.largestUndimmedDetentIdentifier = .large
        }
        GradientHelper.applyShinyDarkGradient(to: self.view)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        GradientHelper.applyShinyDarkGradient(to: self.view)
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlaylistCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func loadPlaylists() {
        
        playlists = PlayListManager.shared.playListArray
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCell", for: indexPath)
        cell.backgroundColor = .clear
        let playlist = playlists[indexPath.row]
        cell.textLabel?.text = playlist.name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlaylist = playlists[indexPath.row]
        addSongToPlaylist(selectedPlaylist)
        dismiss(animated: true, completion: nil)
    }

    private func addSongToPlaylist(_ playlist: Playlist) {
        guard let song = selectedSong else {
            print("Error: No selected song to add.")
            return
        }

        if let index = PlayListManager.shared.playListArray.firstIndex(where: { $0.id == playlist.id }) {
            var targetPlaylist = PlayListManager.shared.playListArray[index]

            if var songs = targetPlaylist.playListSongs {
                if !songs.contains(where: { $0.id == song.id }) {
                    songs.append(song)
                    targetPlaylist.playListSongs = songs
                    PlayListManager.shared.playListArray[index] = targetPlaylist
                } else {
                    print("Song already exists in the playlist")
                }
            } else {
                targetPlaylist.playListSongs = [song]
                PlayListManager.shared.playListArray[index] = targetPlaylist
            }
        } else {
            print("Error: Playlist not found in PlayListManager.")
        }
    }

}
