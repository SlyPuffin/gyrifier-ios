//
//  Router.swift
//  gyrifier
//
//  Created by   on 3/13/23.
//

import Foundation

enum Views: Equatable {
    case home, review(timeLimit: Double)
}

class Navigator: ObservableObject {
    @Published var currentView = Views.home

    func changeView(nextView: Views) {
        DispatchQueue.main.async {
            self.currentView = nextView
        }
    }
    
    func changeViewToReview(timeLimit: Double) {
        DispatchQueue.main.async {
            self.currentView = Views.review(timeLimit: timeLimit)
        }
    }
}
