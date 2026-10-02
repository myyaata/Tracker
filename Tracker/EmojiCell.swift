//
//  EmojiCell.swift
//  Tracker
//
//  Created by арина сильченко on 2.10.26.
//

import UIKit

final class EmojiCell: UICollectionViewCell {
    static let reuseIdentifier = "EmojiCell"
    
    private let emojiLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        emojiLabel.font = .systemFont(ofSize: 32, weight: .bold)
        
        contentView.addSubview(emojiLabel)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    func configure(emoji: String, isSelected: Bool) {
        emojiLabel.text = emoji
        let color = isSelected ? UIColor(named: "Light Gray") : .clear
        contentView.backgroundColor = color
    }
}
