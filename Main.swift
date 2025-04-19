//
//  ThousandEyes_TakeHomeApp.swift
//  ThousandEyes-TakeHome
//
//  Created by Aleksandar Yordanov on 10/04/2025.
//

import SwiftUI
import SDWebImageSVGCoder

@main
struct ThousandEyes_TakeHomeApp: App {
    init() {
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
        // Adding the SVGCoder to enable SVG rendering
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
