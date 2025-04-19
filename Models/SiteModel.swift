//
//  SiteModel.swift
//  ThousandEyes-TakeHome
//
//  Created by Aleksandar Yordanov on 17/04/2025.
//

import Foundation

struct Site: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let url: URL
    let icon: URL
    let description: String

    init(from decoder: Decoder) throws { // Construct site object directly from JSON decoder.
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        url = try container.decode(URL.self, forKey: .url)
        icon = try container.decode(URL.self, forKey: .icon) // Load icons as URLs to allow SDWebImage loading.
        description = try container.decode(String.self, forKey: .description)
        id = UUID()
    }
}
