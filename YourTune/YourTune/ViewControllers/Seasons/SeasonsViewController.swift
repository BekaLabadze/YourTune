//
//  SeasonsViewController.swift
//  YourTune
//
//  Created by Beka on 29.01.25.
//

import UIKit

class SeasonsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var viewModel: SeasonsViewModel
    private let tableView = UITableView()
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
        updateSeasons()
    }

    private func configureUI() {
        setupTableView()
        setupHeaderView()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SeasonCell.self, forCellReuseIdentifier: "SeasonCell")
        tableView.backgroundColor = UIColor(hex: "#FFFFFF")
        tableView.separatorColor = UIColor(hex: "#E5E5E5")
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupHeaderView() {
        let headerContainer = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 600))

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        if let imageURL = URL(string: viewModel.tvShow.image) {
            URLSession.shared.dataTask(with: imageURL) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                }
            }.resume()
        } else {
            imageView.image = UIImage(systemName: "photo")
        }

        if ThemeManager.shared.isDarkMode {
            let gradientLayer = ThemeManager.shared.uiKitBackgroundGradient
            gradientLayer.frame = headerContainer.bounds
            headerContainer.layer.insertSublayer(gradientLayer, at: 0)
        } else {
            headerContainer.backgroundColor = .adjustedWhite
        }

        headerContainer.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: headerContainer.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: -20)
        ])

        tableView.tableHeaderView = headerContainer
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
            view.backgroundColor = .adjustedWhite
            tableView.backgroundColor = .clear
        }
        updateSeasons()
    }

    func updateSeasons() {
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.seasonsCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SeasonCell", for: indexPath) as? SeasonCell else {
            return UITableViewCell()
        }
        cell.backgroundColor = UIColor(hex: "#F3F3F3")
        cell.textLabel?.textColor = UIColor(hex: "#191414")
        cell.detailTextLabel?.textColor = UIColor(hex: "#535353")
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor(hex: "#D3EBCD")
        cell.selectedBackgroundView = selectedView
        let season = viewModel.getSeason(at: indexPath.row)
        cell.configure(viewModel.tvShow, season)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episodesVC = EpisodesViewController(
            viewModel: EpisodesViewModel(
                season: viewModel.getSeason(at: indexPath.row),
                tvShowObject: viewModel.tvShow
            )
        )
        navigationController?.pushViewController(episodesVC, animated: true)
    }

    deinit {
        if let observer = themeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

