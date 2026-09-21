//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by арина сильченко on 20.09.26.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func trackerCellDidTapCompleteButton(_ cell: TrackerCollectionViewCell)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "TrackerCollectionViewCell"
    
    weak var delegate: TrackerCellDelegate?
    
    private let cardView = UIView()
    private let emojiLabel = UILabel()
    private let nameLabel = UILabel()
    private let counterLabel = UILabel()
    private let completeButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    private func setupLayout() {
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
        
        let emojiBackground = UIView()
        emojiBackground.backgroundColor =  UIColor.white.withAlphaComponent(0.3)
        emojiBackground.translatesAutoresizingMaskIntoConstraints = false
        emojiBackground.layer.cornerRadius = 12
        emojiBackground.clipsToBounds = true
        cardView.addSubview(emojiBackground)
        
        emojiLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        emojiLabel.textAlignment = .center
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiBackground.addSubview(emojiLabel)
        
        nameLabel.font = .systemFont(ofSize: 12, weight: .medium)
        nameLabel.textColor = .white
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(nameLabel)
        
        counterLabel.font = .systemFont(ofSize: 12, weight: .medium)
        counterLabel.textColor = .label
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(counterLabel)
        
        completeButton.layer.cornerRadius = 17
        completeButton.tintColor = .white
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(completeButton)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiBackground.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiBackground.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiBackground.widthAnchor.constraint(equalToConstant: 24),
            emojiBackground.heightAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackground.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackground.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            counterLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 16),
            counterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            counterLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            completeButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            completeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    func configure(with tracker: Tracker, isCompleted: Bool, completedDaysCount: Int, isFutureDate: Bool) {
        cardView.backgroundColor = UIColor(named: tracker.color)
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        counterLabel.text = pluralizedDaysString(completedDaysCount)
        let imageName = isCompleted ? "checkmark" : "plus"
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        completeButton.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
        completeButton.backgroundColor = UIColor(named: tracker.color)
        if isFutureDate {
            completeButton.alpha = 0.3
        } else {
            completeButton.alpha = isCompleted ? 0.3 : 1.0
        }
        completeButton.isEnabled = !isFutureDate
    }
    
    @objc private func completeButtonTapped() {
        delegate?.trackerCellDidTapCompleteButton(self)
    }
    
    private func pluralizedDaysString(_ count: Int) -> String {
        let remainder100 = count % 100
        let remainder10 = count % 10
        
        let word: String
        if remainder100 >= 11 && remainder100 <= 14 {
            word = "дней"
        } else if remainder10 == 1 {
            word = "день"
        } else if remainder10 >= 2 && remainder10 <= 4 {
            word = "дня"
        } else {
            word = "дней"
        }
        return "\(count) \(word)"
    }
}
