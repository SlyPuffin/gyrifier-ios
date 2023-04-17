//
//  ReviewViewModel.swift
//  gyrifier
//
//  Created by   on 3/23/23.
//

import Foundation
import CoreData
import SwiftUI

enum CardSide {
    case front, back, expansion_1, expansion_2, expansion_3
}

class ReviewViewModel: ObservableObject {
    @Published var isFinished = false
    @Published var currentCard: Card = Card()
    @Published var isLoading = true
    @Published var cardSide: CardSide = .front
    private var shuffledCards: [Card] = []
    private var timer: Timer?
    private var currentIndex = 0
    private var timeLimit: Double = -1.0
    private var isOvertime = false
    private var reviewTime = 0.0
    private var startTime = 0.0
    private var stopTime = 0.0
    
    func getCardContent() -> String {
        if isLoading {
            return "Loading..."
        }
        switch cardSide {
        case .front:
            return currentCard.cardFront ?? "Loading..."
        case .back:
            return currentCard.cardBack ?? "Loading..."
        case .expansion_3:
            return currentCard.expansion_3 ?? "Loading..."
        case .expansion_2:
            return currentCard.expansion_22 ?? "Loading..."
        case .expansion_1:
            return currentCard.expansion_1 ?? "Loading..."
        }
    }
    
    func getCardHeader() -> String {
        switch cardSide {
        case .front:
            return "Front"
        case .back:
            return "Back"
        case .expansion_3:
            return "Expansion 3"
        case .expansion_2:
            return "Expansion 2"
        case .expansion_1:
            return currentCard.level == 2 ? "Expansion" : "Expansion 2"
        }
    }
    
    func getCardBackgroundColor() -> Color {
        if isLoading {
            return Color("lvl_1_front")
        }
        switch cardSide {
        case .front:
            if currentCard.level == 1 { return Color("lvl_1_front") }
            if currentCard.level == 2 { return Color("lvl_2_front") }
            if currentCard.level == 3 { return Color("lvl_3_front") }
            if currentCard.level == 4 { return Color("lvl_4_front") }
        case .back:
            if currentCard.level == 1 { return Color("lvl_1_back") }
            if currentCard.level == 2 { return Color("lvl_2_back") }
            if currentCard.level == 3 { return Color("lvl_3_back") }
            if currentCard.level == 4 { return Color("lvl_4_back") }
        case .expansion_3:
            return Color("lvl_4_expansion_3")
        case .expansion_2:
            if currentCard.level == 3 { return Color("lvl_3_expansion_2") }
            if currentCard.level == 4 { return Color("lvl_4_expansion_2") }
        case .expansion_1:
            if currentCard.level == 2 { return Color("lvl_2_expansion") }
            if currentCard.level == 3 { return Color("lvl_3_expansion_1") }
            if currentCard.level == 4 { return Color("lvl_4_expansion_1") }
        }
        return Color("lvl_1_front")
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
        switch cardSide {
        case .front:
            if (currentCard.level >= 4) {
                changeCardSide(.expansion_3)
            } else if (currentCard.level >= 3) {
                changeCardSide(.expansion_2)
            } else if (currentCard.level >= 2) {
                changeCardSide(.expansion_1)
            } else {
                changeCardSide(.back)
            }
        case .expansion_3:
            changeCardSide(.expansion_2)
        case .expansion_2:
            changeCardSide(.expansion_1)
        case .expansion_1:
            changeCardSide(.back)
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
    
    private func changeCardSide(_ cs: CardSide) {
        cardSide = cs
    }
    
    private func canCardLevelUp(card: Card) -> Bool {
        return ((card.level == 1 && card.experiencePoints == 3) || (card.level == 2 && card.experiencePoints == 8) || (card.level == 3 && card.experiencePoints == 15) || (card.level == 4 && card.experiencePoints == 25))
    }
    
    private func iterateCards(viewContext: NSManagedObjectContext) {
        currentIndex += 1
        updateReviewedCard(card: currentCard, viewContext: viewContext)
        if (isOvertime || currentIndex >= shuffledCards.count) {
            finishReview()
        } else {
            currentCard = shuffledCards[currentIndex]
            changeCardSide(.front)
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
        else if card.level == 4 {
            if card.experiencePoints < 25 {
                return card.experiencePoints + 1
            }
            else {
                return 25
            }
        }
        else if card.level == 3 {
            if card.experiencePoints < 15 {
                return card.experiencePoints + 1
            }
            else {
                return 15
            }
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
