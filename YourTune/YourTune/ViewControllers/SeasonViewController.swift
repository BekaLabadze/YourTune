//
//  SeasonViewController.swift
//  YourTune
//
//  Created by Beka on 16.01.25.
//

import UIKit

class SeasonsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var tvShow: TVShow!
    var userViewModel: UserViewModel!
    private let seasonView = UITableView()
    private var themeObserver: NSObjectProtocol?

    init(tvShow: TVShow, userViewModel: UserViewModel) {
        self.tvShow = tvShow
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyTheme()
    }

    private func configureUI() {
        seasonView.delegate = self
        seasonView.dataSource = self
        seasonView.register(SeasonCell.self, forCellReuseIdentifier: "SeasonCell")
        seasonView.translatesAutoresizingMaskIntoConstraints = false
        seasonView.backgroundColor = .clear
        view.addSubview(seasonView)

        NSLayoutConstraint.activate([
            seasonView.topAnchor.constraint(equalTo: view.topAnchor),
            seasonView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            seasonView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            seasonView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
        if ThemeManager.shared.isDarkMode {
            let gradientLayer = ThemeManager.shared.uiKitBackgroundGradient
            view.layer.insertSublayer(gradientLayer, at: 0)
            view.backgroundColor = .clear
        } else {
            view.backgroundColor = .white
            seasonView.backgroundColor = .clear
        }
        
        seasonView.reloadData()
    }

    func updateSeasons() {
        seasonView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tvShow.seasons.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = seasonView.dequeueReusableCell(withIdentifier: "SeasonCell", for: indexPath) as? SeasonCell else {
            return UITableViewCell()
        }
        let specificSeason = tvShow.seasons[indexPath.row]
        cell.configure(tvShow, specificSeason)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episodesVC = EpisodesViewController()
        episodesVC.season = tvShow.seasons[indexPath.row]
        episodesVC.tvShowObject = tvShow
        episodesVC.userViewModel = userViewModel
        navigationController?.pushViewController(episodesVC, animated: true)
    }

    deinit {
        if let observer = themeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
