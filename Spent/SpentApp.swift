//
//  SpentApp.swift
//  Spent
//
//  Created by Jakub Majka on 8/12/24.
//

import SwiftUI
import SwiftData

@main
struct SpentApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: SpentItem.self)
    }
}
         
