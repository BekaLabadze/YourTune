//
//  ErrorViewController.swift
//  YourTune
//
//  Created by Beka on 01.02.25.
//

import UIKit

class ErrorViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .black
        
        let errorLabel = UILabel()
        errorLabel.text = "Error"
        errorLabel.textColor = .red
        errorLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        errorLabel.textAlignment = .center
        
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorLabel)

        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
