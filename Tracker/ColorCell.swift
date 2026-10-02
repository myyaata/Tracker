//
//  ColorCell.swift
//  Tracker
//
//  Created by арина сильченко on 2.10.26.
//

import UIKit

final class ColorCell: UICollectionViewCell {
    static let reuseIdentifier = "ColorCell"
    
    private let colorRect = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        colorRect.layer.cornerRadius = 8
        colorRect.layer.masksToBounds = true
        contentView.layer.cornerRadius = 8
        contentView.addSubview(colorRect)
        colorRect.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorRect.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorRect.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorRect.widthAnchor.constraint(equalToConstant: 40),
            colorRect.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    func configure(colorName: String, isSelected: Bool) {
        let color = UIColor(named: colorName)
        colorRect.backgroundColor = color
        contentView.layer.borderWidth = isSelected ? 3 : 0
        let borderColor = isSelected ? color?.withAlphaComponent(0.3) : .clear
        contentView.layer.borderColor = borderColor?.cgColor
    }
}
