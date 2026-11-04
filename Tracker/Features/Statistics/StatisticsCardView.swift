//
//  StatisticsCardView.swift
//  Tracker
//
//  Created by арина сильченко on 4.11.26.
//

import UIKit

final class StatisticsCardView: UIView {
    private let valueLabel = UILabel()
    private let titleLabel = UILabel()
    private let gradientLayer = CAGradientLayer()
    private let borderMask = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
    
    private func setupLayout() {
        valueLabel.font = .systemFont(ofSize: 34, weight: .bold)
        valueLabel.textColor = UIColor(named: "Black [day]")
        
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = UIColor(named: "Black [day]")

        addSubview(valueLabel)
        addSubview(titleLabel)
        
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
        
        layer.cornerRadius = 16
        gradientLayer.colors = [
            UIColor(red: 0.99, green: 0.30, blue: 0.29, alpha: 1).cgColor,
            UIColor(red: 0.27, green: 0.90, blue: 0.62, alpha: 1).cgColor,
            UIColor(red: 0.00, green: 0.48, blue: 0.98, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        borderMask.lineWidth = 1
        borderMask.fillColor = UIColor.clear.cgColor
        borderMask.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = borderMask
        layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        borderMask.path = UIBezierPath(roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5), cornerRadius: 16).cgPath
    }
    
    func configure(value: Int, title: String) {
        valueLabel.text = "\(value)"
        titleLabel.text = title
    }
    
    
}
