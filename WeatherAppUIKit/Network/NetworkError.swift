//
//  NetworkError.swift
//  WeatherAppUIKit
//
//  Created by Sergey Abadzhev on 31.03.26.
//

import Foundation

enum NetworkError: LocalizedError, Equatable {
    case invalidURL
    case noInternetConnection
    case timeout
    case serverError(statusCode: Int)
    case decodingError(Error)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return L10n.Error.invalidURL
        case .noInternetConnection:
            return L10n.Error.noInternet
        case .timeout:
            return L10n.Error.timeout
        case .serverError(let code):
            return L10n.Error.server(code)
        case .decodingError:
            return L10n.Error.decoding
        case .unknown(let error):
            return error.localizedDescription
        }
    }

    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.noInternetConnection, .noInternetConnection):
            return true
        case (.timeout, .timeout):
            return true
        case (.serverError(let l), .serverError(let r)):
            return l == r
        case (.decodingError(let l), .decodingError(let r)):
            return l.localizedDescription == r.localizedDescription
        case (.unknown(let l), .unknown(let r)):
            return l.localizedDescription == r.localizedDescription
        default:
            return false
        }
    }
}
