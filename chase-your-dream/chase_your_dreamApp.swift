//
//  chase_your_dreamApp.swift
//  chase-your-dream
//
//  Created by HuyNQ1 on 24/4/26.
//

import SwiftUI
import SwiftData

@main
struct chase_your_dreamApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(PersistenceController.shared)
        }
    }
}
