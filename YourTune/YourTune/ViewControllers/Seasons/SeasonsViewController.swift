//
//  SeasonsViewController.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import UIKit

class SeasonsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var viewModel: SeasonsViewModel
    private let seasonView = UITableView()
    private var themeObserver: NSObjectProtocol?
    
    init(viewModel: SeasonsViewModel) {
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
        seasonView.delegate = self
        seasonView.dataSource = self
        seasonView.register(SeasonCell.self, forCellReuseIdentifier: "SeasonCell")
    }
    
    private func setupTableViewConstraints() {
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
        updateSeasons()
    }

    func updateSeasons() {
        seasonView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.seasonsCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = seasonView.dequeueReusableCell(withIdentifier: "SeasonCell", for: indexPath) as? SeasonCell else {
            return UITableViewCell()
        }
        let specificSeason = viewModel.getSeason(at: indexPath.row)
        cell.configure(viewModel.tvShow, specificSeason)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episodesVC = EpisodesViewController(
            viewModel: EpisodesViewModel(
                season: viewModel.getSeason(at: indexPath.row),
                tvShowObject: viewModel.tvShow
            )
        )
        episodesVC.userViewModel = viewModel.userViewModel
        navigationController?.pushViewController(episodesVC, animated: true)
    }

    deinit {
        if let observer = themeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
