//
//  DailyForecastCell.swift
//  WeatherAppUIKit
//
//  Created by Sergey Abadzhev on 31.03.26.
//

import UIKit

final class DailyForecastCell: UITableViewCell {

    static let reuseID = "DailyForecastCell"

    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        iv.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let lowLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let highLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tempBar: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        v.layer.cornerRadius = 3
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let tempFill: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 3
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private var fillLeadingConstraint: NSLayoutConstraint!
    private var fillTrailingConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupViews() {
        contentView.addSubview(dayLabel)
        contentView.addSubview(iconView)
        contentView.addSubview(lowLabel)
        contentView.addSubview(tempBar)
        contentView.addSubview(highLabel)
        tempBar.addSubview(tempFill)

        fillLeadingConstraint = tempFill.leadingAnchor.constraint(equalTo: tempBar.leadingAnchor)
        fillTrailingConstraint = tempFill.trailingAnchor.constraint(equalTo: tempBar.trailingAnchor)

        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: 50).withPriority(.defaultHigh),

            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dayLabel.widthAnchor.constraint(equalToConstant: 50),

            iconView.leadingAnchor.constraint(equalTo: dayLabel.trailingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),

            lowLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            lowLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            lowLabel.widthAnchor.constraint(equalToConstant: 34),

            tempBar.leadingAnchor.constraint(equalTo: lowLabel.trailingAnchor, constant: 8),
            tempBar.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            tempBar.heightAnchor.constraint(equalToConstant: 6),

            highLabel.leadingAnchor.constraint(equalTo: tempBar.trailingAnchor, constant: 8),
            highLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            highLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            highLabel.widthAnchor.constraint(equalToConstant: 34),

            tempFill.topAnchor.constraint(equalTo: tempBar.topAnchor),
            tempFill.bottomAnchor.constraint(equalTo: tempBar.bottomAnchor),
            fillLeadingConstraint,
            fillTrailingConstraint,
        ])
    }

    func configure(dayName: String, conditionCode: Int, low: Double, high: Double, globalLow: Double, globalHigh: Double) {
        dayLabel.text = dayName
        iconView.image = UIImage(systemName: WeatherIconMapper.sfSymbol(for: conditionCode))
        lowLabel.text = "\(Int(low.rounded()))°"
        highLabel.text = "\(Int(high.rounded()))°"

        let range = globalHigh - globalLow
        guard range > 0 else {
            fillLeadingConstraint.constant = 0
            fillTrailingConstraint.constant = 0
            return
        }

        let leadingFraction = CGFloat((low - globalLow) / range)
        let trailingFraction = CGFloat((globalHigh - high) / range)

        setNeedsLayout()
        layoutIfNeeded()

        let barWidth = tempBar.bounds.width
        fillLeadingConstraint.constant = barWidth * leadingFraction
        fillTrailingConstraint.constant = -(barWidth * trailingFraction)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradient = tempFill.layer.sublayers?.first as? CAGradientLayer {
            gradient.frame = tempFill.bounds
        } else {
            let gradient = CAGradientLayer()
            gradient.colors = [
                UIColor.systemBlue.cgColor,
                UIColor.systemGreen.cgColor,
                UIColor.systemYellow.cgColor,
                UIColor.systemOrange.cgColor,
            ]
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
            gradient.cornerRadius = 3
            gradient.frame = tempFill.bounds
            tempFill.layer.addSublayer(gradient)
        }
    }
}

private extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
