//
//  SiteRowView.swift
//  ThousandEyes-TakeHome
//
//  Created by Aleksandar Yordanov on 17/04/2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct SiteRowView: View {
    let site: Site

    var body: some View {
        HStack {
            WebImage(url: site.icon) { phase in
                switch phase {
                case .empty:
                    ProgressView() // In case of image currently being pulled.
                case .success(let img):
                    img.resizable().scaledToFit() // Successful image load.
                case .failure:
                    Image(systemName: "photo") // Placeholder image in case of load failure.
                @unknown default:
                    EmptyView() // Unknown error case.
                }
            }
            .frame(width: 40, height: 40)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(site.name)
                    .font(.headline)
                Text(site.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
