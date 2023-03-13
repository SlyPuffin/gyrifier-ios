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
    @ObservedObject var navigator = Navigator()
    
    init() {
        navigator.changeView(nextView: Views.home)
    }

    var body: some Scene {
        WindowGroup {
            switch navigator.currentView {
            case .home:
                HomeView()
                    .environmentObject(navigator)
            case .add:
                AddCardView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(navigator)
            case .edit:
                EditView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(navigator)
            case .review(let timeLimit):
                ReviewView(timeLimit: timeLimit)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(navigator)
            }
        }
    }
}
