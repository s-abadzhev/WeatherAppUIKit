//
//  GlassCardView.swift
//  WeatherAppUIKit
//
//  Created by Sergey Abadzhev on 31.03.26.
//

import UIKit

final class GlassCardView: UIView {
    private let blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let v = UIVisualEffectView(effect: effect)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 14
        clipsToBounds = true
        insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}
