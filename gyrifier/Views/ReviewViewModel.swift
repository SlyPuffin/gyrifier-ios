//
//  ReviewViewModel.swift
//  gyrifier
//
//  Created by   on 3/23/23.
//

import Foundation
import CoreData
import SwiftUI

enum FlippedStatus {
    case front, back, expansion_1//, expansion_2, expansion_3
}

class ReviewViewModel: ObservableObject {
    @Published var isFinished = false
    @Published var currentCard: Card = Card()
    @Published var isLoading = true
    @Published var flippedStatus: FlippedStatus = .front
    private var shuffledCards: [Card] = []
    private var timer: Timer?
    private var currentIndex = 0
    private var timeLimit: Double = -1.0
    private var isOvertime = false
    private var reviewTime = 0.0
    private var startTime = 0.0
    private var stopTime = 0.0
    
    func getBackgroundColor() -> Color {
        switch flippedStatus {
        case .front:
            return .clear
        case .back:
            return .blue
        case .expansion_1:
            return .mint
        }
    }
    
    func getForegroundColor() -> Color {
        switch flippedStatus {
        case .front:
            return .blue
        case .back:
            return .white
        case .expansion_1:
            return .black
        }
    }

    func getBorderColor() -> Color {
        switch flippedStatus {
        case .front:
            return .blue
        case .back:
            return .clear
        case .expansion_1:
            return .clear
        }
    }
    
    func getCardHeader() -> String {
        switch flippedStatus {
        case .front:
            return "Front"
        case .back:
            return "Back"
        case .expansion_1:
            return "Expansion"
        }
    }
    
    func getCardContent() -> String {
        switch flippedStatus {
        case .front:
            return currentCard.cardFront ?? "Loading..."
        case .back:
            return currentCard.cardBack ?? "Loading..."
        case .expansion_1:
            return currentCard.expansion_1 ?? "Loading..."
        }
    }
    
    func setTimeLimit(timeLimit: Double) {
        self.timeLimit = timeLimit
    }
    
    func prepareCards(cards: [Card]) {
        shuffledCards = cards.filter({isStudyDateTodayOrEarlier($0.nextAppearance!)}).shuffled()
        if (shuffledCards.isEmpty) {
            finishReview()
        }
        else {
            currentIndex = 0
            currentCard = shuffledCards[currentIndex]
            isLoading = false
        }
    }
    
    func tapCard(viewContext: NSManagedObjectContext) {
        switch flippedStatus {
        case .front:
            if (currentCard.level >= 2) {
                changeFlippedStatus(.expansion_1)
            } else {
                changeFlippedStatus(.back)
            }
        case .expansion_1:
            changeFlippedStatus(.back)
        case .back:
            iterateCards(viewContext: viewContext)
        }
    }
    
    // TODO: Add unit tests
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            self.reviewTime += 0.1
            if (self.timeLimit != -1.0 && self.reviewTime > self.timeLimit) {
                self.isOvertime = true
            }
        }
        startTime = reviewTime
    }
    
    func checkForLevelUps(cards: [Card]) -> Bool {
        return !cards.filter({canCardLevelUp(card: $0)}).isEmpty
    }
    
    func returnLevelUps(cards: [Card]) -> [Card] {
        return cards.filter({canCardLevelUp(card: $0)}).shuffled()
    }
    
    func changeFlippedStatus(_ fs: FlippedStatus) {
        flippedStatus = fs
    }
    
    private func canCardLevelUp(card: Card) -> Bool {
        return (card.level == 1 && card.experiencePoints == 3)
//        return ((card.level == 1 && card.experiencePoints == 3) || (card.level == 2 && card.experiencePoints == 8) || (card.level == 3 && card.experiencePoints == 15) || (card.level == 4 && card.experiencePoints == 25))
    }
    
    private func iterateCards(viewContext: NSManagedObjectContext) {
        currentIndex += 1
        updateReviewedCard(card: currentCard, viewContext: viewContext)
        if (isOvertime || currentIndex >= shuffledCards.count) {
            finishReview()
        } else {
            currentCard = shuffledCards[currentIndex]
            changeFlippedStatus(.front)
        }
    }
    
    private func finishReview() {
        isFinished = true
        timer?.invalidate()
    }
    
    private func isStudyDateTodayOrEarlier(_ date: Date) -> Bool {
        return (Calendar.current.isDateInToday(date) || date.timeIntervalSinceNow.sign == FloatingPointSign.minus)
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
        else if card.level == 2 {
            if card.experiencePoints < 8 {
                return card.experiencePoints + 1
            }
            else {
                return 8
            }
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
