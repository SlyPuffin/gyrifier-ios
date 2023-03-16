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
        if (cards.isEmpty) {
            isFinished = true
        } else {
            shuffledCards = cards.filter({isStudyDateToday($0.nextAppearance ?? Date())}).shuffled()
            currentIndex = 0
            currentCard = shuffledCards[currentIndex]
            isLoading = false
        }
    }
    
    private func iterateCards() {
        currentIndex += 1
        updateReviewedCard(card: currentCard)
        if (isOvertime || currentIndex >= cards.count) {
            finishReview()
        } else {
            currentCard = shuffledCards[currentIndex]
            toggleFlip()
        }
    }
    
    private func isStudyDateToday(_ date: Date) -> Bool {
        var dayMatch = Calendar.current.component(.day, from: date) == Calendar.current.component(.day, from: Date())
        var monthMatch = Calendar.current.component(.month, from: date) == Calendar.current.component(.month, from: Date())
        var yearMatch = Calendar.current.component(.year, from: date) == Calendar.current.component(.year, from: Date())
        return (dayMatch && monthMatch && yearMatch)
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
            card.nextAppearance = Date().addingTimeInterval(24 * 60 * Double(card.timesSeen))
            // TODO: Calculate experience points
            if card.experiencePoints < 3 {
                card.experiencePoints += 1
                card.level = 1
            }
            // TODO: Calculate time spent on card
            
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
        }
    }
}

struct ReviewView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewView(timeLimit: 300.0)
    }
}
