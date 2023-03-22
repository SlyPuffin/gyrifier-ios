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
            isFinished = true
        }
        else {
            currentIndex = 0
            currentCard = shuffledCards[currentIndex]
            isLoading = false
        }
    }
    
    private func iterateCards() {
        currentIndex += 1
        updateReviewedCard(card: currentCard)
        if (isOvertime || currentIndex >= shuffledCards.count) {
            finishReview()
        } else {
            currentCard = shuffledCards[currentIndex]
            toggleFlip()
        }
    }
    
    private func isStudyDateToday(_ date: Date) -> Bool {
        return date.timeIntervalSinceNow.sign == FloatingPointSign.minus
    }
    
    private func finishReview() {
        isFinished = true
        timer?.invalidate()
    }
    
    private func toggleFlip() {
        isFlipped.toggle()
    }
    
    // TODO: Fix this re-declaration
    private func updateReviewedCard(card: Card) {
        viewContext.perform {
            // Modify the properties of the fetched object.
            card.dateLastSeen = Date()
            card.timesSeen += 1
            // TODO: Properly calculate next appearance
            card.nextAppearance = Date().addingTimeInterval(24 * 60 * 60 * Double(card.timesSeen))
            // TODO: Calculate experience points
            if card.experiencePoints < 3 {
                card.experiencePoints += 1
                card.level = 1
            }
            stopTime = reviewTime
            let timeSpent = stopTime - startTime
            let newAvg = (timeSpent + (card.avgTimeSpent * Double(card.timesSeen - 1))) / Double(card.timesSeen)
            card.avgTimeSpent = newAvg
            startTime = reviewTime
            
            do {
                // Save the context to persist the changes.
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
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
}

struct ReviewView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewView(timeLimit: 300.0)
    }
}
