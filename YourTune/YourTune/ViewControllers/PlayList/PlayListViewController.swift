//
//  PlayListViewController.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import UIKit

class PlayListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var viewModel: PlayListViewModel
    let tableView = UITableView()
    var onPlaylistSelected: ((Playlist) -> Void)?
    
    init(viewModel: PlayListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        GradientHelper.applyShinyDarkGradient(to: self.view)
        title = "Select Playlist"
        if ThemeManager.shared.isDarkMode {
            
        }
        GradientHelper.applyGradientBackground(to: tableView)
        setupTableView()
        viewModel.fetchPlaylists { self.tableView.reloadData() }
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.playlists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCell", for: indexPath)
        cell.backgroundColor = .clear
        let playlist = viewModel.playlists[indexPath.row]
        cell.textLabel?.text = playlist.name
        cell.textLabel?.textColor = ThemeManager.shared.uiKitTextColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlaylist = viewModel.playlists[indexPath.row]
        onPlaylistSelected?(selectedPlaylist)
        dismiss(animated: true)
    }
}
