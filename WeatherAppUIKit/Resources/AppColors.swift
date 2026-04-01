//
//  AppColors.swift
//  WeatherAppUIKit
//
//  Created by Sergey Abadzhev on 31.03.26.
//

import UIKit

enum AppColors {

    // MARK: - Background gradient (top → bottom)

    static let gradientTop    = UIColor(red: 0.15, green: 0.35, blue: 0.75, alpha: 1)
    static let gradientMid    = UIColor(red: 0.30, green: 0.55, blue: 0.90, alpha: 1)
    static let gradientBottom = UIColor(red: 0.45, green: 0.70, blue: 1.00, alpha: 1)

    // MARK: - Text

    /// Основной белый текст
    static let primaryText   = UIColor.white
    /// Приглушённый текст (заголовки секций, подписи)
    static let secondaryText = UIColor.white.withAlphaComponent(0.7)
    /// Ещё более приглушённый текст (минимальная температура дня)
    static let tertiaryText  = UIColor.white.withAlphaComponent(0.6)

    // MARK: - UI Elements

    /// Разделители внутри карточек
    static let separator        = UIColor.white.withAlphaComponent(0.3)
    /// Фон кнопки «Повторить»
    static let buttonBackground = UIColor.white.withAlphaComponent(0.25)
    /// Фон трека температурного бара
    static let tempBarTrack     = UIColor.white.withAlphaComponent(0.2)

    // MARK: - Temperature bar gradient

    static let tempGradient: [CGColor] = [
        UIColor.systemBlue.cgColor,
        UIColor.systemGreen.cgColor,
        UIColor.systemYellow.cgColor,
        UIColor.systemOrange.cgColor,
    ]
}
