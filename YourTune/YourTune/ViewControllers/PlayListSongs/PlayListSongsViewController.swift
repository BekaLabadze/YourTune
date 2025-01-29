//
//  PlayListSongsViewController.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import UIKit

class PlaylistSongsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let tableView = UITableView()
    private var viewModel: PlaylistSongsViewModel
    
    init(viewModel: PlaylistSongsViewModel) {
        self.viewModel = viewModel
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
        view.backgroundColor = .brown
        title = viewModel.playlist?.name ?? "Playlist"

        view.addSubview(tableView)
        setupTableView()
        setupTableViewConstraints()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SongCell")
    }
    
    private func setupTableViewConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.playlistSongsCount ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath)
        if let song = viewModel.getSong(on: indexPath.row) {
            cell.textLabel?.text = song.title
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let song = viewModel.getSong(on: indexPath.row) else { return }
        let playerVC = PlayerViewController(
            viewModel: .init(
                songArray: nil,
                selectedSong: song
            ),
            isFromSwiftUI: false
        )
        navigationController?.pushViewController(playerVC, animated: true)
    }
}
