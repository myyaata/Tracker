//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by арина сильченко on 1.11.26.
//

import UIKit

final class OnboardingPageViewController: UIViewController {
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    
    init(imageName: String, title: String) {
        super.init(nibName: nil, bundle: nil)
        imageView.image = UIImage(named: imageName)
        titleLabel.text = title
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = UIColor(named: "Black [day]")
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -270)
        ])
    }
}
