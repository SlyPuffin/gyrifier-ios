//
//  ReviewViewModel.swift
//  gyrifier
//
//  Created by   on 3/23/23.
//

import Foundation
import CoreData

class ReviewViewModel: ObservableObject {
    @Published var isFinished = false
    @Published var currentCard: Card = Card()
    @Published var isLoading = true
    @Published var isFlipped = false
    private var shuffledCards: [Card] = []
    private var timer: Timer?
    private var currentIndex = 0
    private var timeLimit: Double = -1.0
    private var isOvertime = false
    private var reviewTime = 0.0
    private var startTime = 0.0
    private var stopTime = 0.0

    func setTimeLimit(timeLimit: Double) {
        self.timeLimit = timeLimit
    }
    
    func prepareCards(cards: [Card]) {
        shuffledCards = cards
        if (shuffledCards.isEmpty) {
            finishReview()
        }
        else {
            currentIndex = 0
            currentCard = shuffledCards[currentIndex]
            isLoading = false
        }
    }
    
    func iterateCards(viewContext: NSManagedObjectContext) {
        currentIndex += 1
        updateReviewedCard(card: currentCard, viewContext: viewContext)
        if (isOvertime || currentIndex >= shuffledCards.count) {
            finishReview()
        } else {
            currentCard = shuffledCards[currentIndex]
            toggleFlip()
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            self.reviewTime += 0.1
            if (self.timeLimit != -1.0 && self.reviewTime > self.timeLimit) {
                self.isOvertime = true
            }
        }
        startTime = reviewTime
    }
    
    func toggleFlip() {
        isFlipped.toggle()
    }
    
    private func finishReview() {
        isFinished = true
        timer?.invalidate()
    }
    
    private func updateReviewedCard(card: Card, viewContext: NSManagedObjectContext) {
        viewContext.perform {
            _ = self.prepReviewedCard(card: card)
            do {
                // Save the context to persist the changes.
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func prepReviewedCard(card: Card) -> Card {
        let result = card
        result.dateLastSeen = Date()
        result.timesSeen += 1
        result.nextAppearance = nextAppearanceFor(card: card)
        result.experiencePoints = experiencePointsFor(card: card)
        result.avgTimeSpent = avgTimeSpentFor(card: card)
        return result
    }
    
    private func nextAppearanceFor(card: Card) -> Date {
        return Date().addingTimeInterval(24 * 60 * 60 * Double(card.timesSeen))
    }
    
    private func experiencePointsFor(card: Card) -> Int16 {
        if card.experiencePoints < 3 {
            return card.experiencePoints + 1
        }
        else {
            return 3
        }
    }
    
    private func avgTimeSpentFor(card: Card) -> Double {
        stopTime = reviewTime
        let timeSpent = stopTime - startTime
        let result = (timeSpent + (card.avgTimeSpent * Double(card.timesSeen - 1))) / Double(card.timesSeen)
        startTime = reviewTime
        return result
    }
}
