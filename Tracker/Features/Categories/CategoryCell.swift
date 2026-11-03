//
//  CategoryCell.swift
//  Tracker
//
//  Created by арина сильченко on 2.11.26.
//

import UIKit

final class CategoryCell: UITableViewCell {
    static let reuseIdentifier = "CategoryCell"
    
    private let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(named: "Background [day]")
        titleLabel.textColor = UIColor(named: "Black [day]")
        titleLabel.font = .systemFont(ofSize: 17)
        titleLabel.lineBreakMode = .byTruncatingTail
        selectionStyle = .none
        tintColor = UIColor(named: "Blue")
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    func configure(title: String, isChecked: Bool) {
        titleLabel.text = title
        accessoryType = isChecked ? .checkmark : .none
    }
}
