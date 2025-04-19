//
//  NetworkingService.swift
//  ThousandEyes-TakeHome
//
//  Created by Aleksandar Yordanov on 17/04/2025.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
}

struct NetworkService {
    private let endpoint: String
    init(endpoint: String = AppConfig.apiBaseURL) {
        self.endpoint = endpoint
    }
    
    func fetchSites() async throws -> [Site] {
        guard let url = URL(string: AppConfig.apiBaseURL) else {
            throw NetworkError.invalidURL
        }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                // Guard and check only for successful error codes, otherwise throw requestFailed
                throw NetworkError.requestFailed
            }
            return try JSONDecoder().decode([Site].self, from: data)
        } catch is DecodingError {
            throw NetworkError.decodingFailed
        } catch {
            throw NetworkError.requestFailed
        }
    }
}
