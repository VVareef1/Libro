//
//  LibroApp.swift
//  Libro
//
//  Created by Wareef Saeed Alzahrani on 06/05/2026.
//

import SwiftUI
import SwiftData
@main
struct LibroApp: App {

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Book.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView2()
        }
        .modelContainer(sharedModelContainer)
    }
}
