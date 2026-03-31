//
//  URLSessionNetworkClient.swift
//  WeatherAppUIKit
//
//  Created by Sergey Abadzhev on 31.03.26.
//

import Foundation

final class URLSessionNetworkClient: NetworkClient, @unchecked Sendable {

    static let shared = URLSessionNetworkClient()

    private let session: URLSessionProtocol
    private let decoder: JSONDecoder

    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session

        let decoder = JSONDecoder()
        self.decoder = decoder
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }

        let urlRequest = URLRequest(url: url, timeoutInterval: 30)

        do {
            let (data, response) = try await session.data(for: urlRequest)
            try validateResponse(response)
            return try decode(data)
        } catch let error as NetworkError {
            throw error
        } catch let urlError as URLError {
            throw mapURLError(urlError)
        } catch {
            throw NetworkError.unknown(error)
        }
    }

    // MARK: - Private

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else { return }

        switch httpResponse.statusCode {
        case 200...299:
            break
        default:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
    }

    private func decode<T: Decodable>(_ data: Data) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }

    private func mapURLError(_ error: URLError) -> NetworkError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .noInternetConnection
        case .timedOut:
            return .timeout
        default:
            return .unknown(error)
        }
    }
}

