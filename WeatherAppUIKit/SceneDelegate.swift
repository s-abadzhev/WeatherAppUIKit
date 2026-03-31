//
//  SceneDelegate.swift
//  WeatherAppUIKit
//
//  Created by Sergey Abadzhev on 31.03.26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let locationService = LocationService()
        let weatherRepository = WeatherRepository(networkClient: URLSessionNetworkClient())
        let viewModel = WeatherViewModel(
            locationService: locationService,
            weatherRepository: weatherRepository
        )
        let viewController = WeatherViewController(viewModel: viewModel)

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        self.window = window
    }
}
