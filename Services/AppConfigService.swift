//
//  AppConfigService.swift
//  ThousandEyes-TakeHome
//
//  Created by Aleksandar Yordanov on 19/04/2025.
//

import Foundation

struct AppConfig {
    private static var config: [String: Any] {
        guard
            let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
            let dict = NSDictionary(contentsOf: url) as? [String: Any]
        else {
            fatalError("Could not find or parse Config.plist.")
            // We use fatalError here as we are entering an unknown state if this fails.
        }
        return dict
    }

    private static func value(forKey key: String) -> String {
        guard let v = config[key] as? String else {
            fatalError("Missing key '\(key)' in Config.plist")
        }
        return v
    }

    static var apiBaseURL: String {
        value(forKey: "API_ENDPOINT")
    }
}
