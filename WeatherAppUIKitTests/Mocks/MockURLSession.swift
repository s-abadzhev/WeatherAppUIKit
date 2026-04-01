//
//  MockURLSession.swift
//  WeatherAppUIKitTests
//
//  Created by Sergey Abadzhev on 01.04.26.
//

import Foundation
@testable import WeatherAppUIKit

final class MockURLSession: URLSessionProtocol {
    private let result: Result<(Data, URLResponse), Error>

    init(data: Data, response: URLResponse) { result = .success((data, response)) }
    init(error: Error)                       { result = .failure(error) }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try result.get()
    }
}
