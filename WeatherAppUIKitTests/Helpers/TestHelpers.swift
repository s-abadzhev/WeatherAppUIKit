//
//  TestHelpers.swift
//  WeatherAppUIKitTests
//
//  Created by Sergey Abadzhev on 01.04.26.
//

import Foundation
import Testing
@testable import WeatherAppUIKit

/// Polls until the ViewModel leaves `.loading`, or returns the current state after max yields.
func awaitNonLoadingState(_ vm: WeatherViewModel, maxYields: Int = 2000) async -> WeatherViewState {
    for _ in 0..<maxYields {
        if case .loading = await vm.state { await Task.yield() } else { return await vm.state }
    }
    return await vm.state
}

/// Yields `count` times, giving spawned Tasks a chance to execute.
func yield(_ count: Int = 200) async {
    for _ in 0..<count { await Task.yield() }
}

/// Builds an HTTPURLResponse with the given status code.
func httpResponse(status: Int, url: URL = URL(string: "https://example.com")!) -> HTTPURLResponse {
    HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil)!
}
