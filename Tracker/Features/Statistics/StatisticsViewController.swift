//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by арина сильченко on 1.09.26.
//

import UIKit
 
final class StatisticsViewController: UIViewController {
    
    private let trackerRecordStore: TrackerRecordStore
    
    private let emptyStateImageView = UIImageView()
    private let emptyStateLabel = UILabel()
    private let emptyStateStack = UIStackView()
    
    private let completedCard = StatisticsCardView()
    
    init(trackerRecordStore: TrackerRecordStore) {
        self.trackerRecordStore = trackerRecordStore
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("statistics.title", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = UIColor(named: "White [day]")
        setupEmptyState()
        setupCard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatistics()
    }
    
    private func setupCard() {
        completedCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(completedCard)

        NSLayoutConstraint.activate([
            completedCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 77),
            completedCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            completedCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            completedCard.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
    
    private func updateStatistics() {
        let completed = trackerRecordStore.fetchRecords().count
        completedCard.configure(value: completed, title: NSLocalizedString("statistics.completed", comment: ""))
        completedCard.isHidden = completed == 0
        emptyStateStack.isHidden = completed > 0
    }
    
    private func setupEmptyState() {
        emptyStateImageView.contentMode = .scaleAspectFit
        emptyStateImageView.image = UIImage(named: "statistics_empty_state")
        
        emptyStateLabel.text = NSLocalizedString("statistics.empty", comment: "")
        emptyStateLabel.font = .systemFont(ofSize: 12, weight: .medium)
        emptyStateLabel.textColor = .label
        emptyStateLabel.textAlignment = .center
        
        emptyStateStack.axis = .vertical
        emptyStateStack.alignment = .center
        emptyStateStack.spacing = 8
        emptyStateStack.addArrangedSubview(emptyStateImageView)
        emptyStateStack.addArrangedSubview(emptyStateLabel)
        
        emptyStateStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateStack)
        
        NSLayoutConstraint.activate([
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyStateStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
