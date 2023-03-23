//
//  ReviewView.swift
//  gyrifier
//
//  Created by   on 3/3/23.
//

import SwiftUI

// TODO: Fix todos inside updateReviewedCard

struct ReviewView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var navigator: Navigator

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.dateCreated, ascending: true)],
        animation: .default)
    private var cards: FetchedResults<Card>
    
    let timeLimit: Double
    
    @State var reviewTime = 0.0
    @State var isOvertime = false
    @State var timer: Timer?
    @State var shuffledCards: [Card] = []
    @State var isFlipped = false
    @State var isFinished = false
    @State var isLoading = true
    @State var currentIndex = 0
    @State var currentCard: Card = Card()
    @State var startTime = 0.0
    @State var stopTime = 0.0
    
    var body: some View {
        HStack {
            Button {
                navigator.changeView(nextView: .home)
            } label: {
                Text("Back")
            }
            .padding()
            Spacer()
        }
        Spacer()
        if isFinished {
            VStack(alignment: .center) {
                HStack(alignment: .center) {
                    Text("Congratulations! You finished!")
                }
            }
            Spacer()
        } else {
            Button {
                if isFlipped {
                    iterateCards()
                } else {
                    toggleFlip()
                }
            } label: {
                HStack(alignment: .center) {
                    VStack(alignment: .center) {
                        if isFlipped {
                            Text("Back")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            if isLoading {
                                Text("Loading...")
                                    .padding()
                            } else {
                                Text(currentCard.cardBack ?? "Loading..")
                                    .foregroundColor(.white)
                                    .padding()
                            }
                        } else {
                            Text("Front")
                                .fontWeight(.bold)
                            if isLoading {
                                Text("Loading...")
                                    .padding()
                            } else {
                                Text(currentCard.cardFront ?? "Loading..")
                                    .padding()
                            }
                        }
                    }
                }
                .padding(30)
                .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(isFlipped ? .blue : .clear)
                    )
                .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.blue, lineWidth: 2)
                    )
            }
            .onAppear() {
                startIteration()
                startTimer()
            }
            Spacer()
        }
    }
    
    private func startIteration() {
        shuffledCards = cards.filter({isStudyDateToday($0.nextAppearance!)}).shuffled()
        if (shuffledCards.isEmpty) {
            finishReview()
        }
        else {
            currentIndex = 0
            currentCard = shuffledCards[currentIndex]
            isLoading = false
        }
    }
    
    private func iterateCards() {
        currentIndex += 1
        updateReviewedCard(card: prepReviewedCard(card: currentCard))
        if (isOvertime || currentIndex >= shuffledCards.count) {
            finishReview()
        } else {
            currentCard = shuffledCards[currentIndex]
            toggleFlip()
        }
    }
    
    private func startTimer() {
        if timeLimit != -1.0 {
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                reviewTime += 0.1
                if (reviewTime > timeLimit) {
                    isOvertime = true
                }
            }
            startTime = reviewTime
        }
    }
    
    private func isStudyDateToday(_ date: Date) -> Bool {
        // TODO: Handle case where evening time practice doesn't spill into next day
        return date.timeIntervalSinceNow.sign == FloatingPointSign.minus
    }
    
    private func finishReview() {
        isFinished = true
        timer?.invalidate()
    }
    
    private func toggleFlip() {
        isFlipped.toggle()
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
    
    private func updateReviewedCard(card: Card) {
        viewContext.perform {
            do {
                // Save the context to persist the changes.
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ReviewView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewView(timeLimit: 300.0)
    }
}
