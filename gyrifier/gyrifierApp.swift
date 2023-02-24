//
//  gyrifierApp.swift
//  gyrifier
//
//  Created by   on 2/23/23.
//

import SwiftUI

@main
struct gyrifierApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
