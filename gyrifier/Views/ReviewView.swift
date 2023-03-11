//
//  ReviewView.swift
//  gyrifier
//
//  Created by   on 3/3/23.
//

import SwiftUI

struct ReviewView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.dateCreated, ascending: true)],
        animation: .default)
    private var cards: FetchedResults<Card>
    @State var shuffledCards: [Card] = []
    @State var isFlipped = false
    @State var isFinished = false
    @State var isLoading = true
    @State var currentIndex = 0
    @State var currentCard: Card = Card()
    
    var body: some View {
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
            //.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            .onAppear() {
                startIteration()
            }
        }
    }
    
    private func startIteration() {
        if (cards.isEmpty) {
            isFinished = true
        } else {
            shuffledCards = cards.shuffled()
            currentIndex = 0
            currentCard = shuffledCards[currentIndex]
            isLoading = false
        }
    }
    
    private func iterateCards() {
        currentIndex += 1
        updateCardLastSeen(card: currentCard)
        if currentIndex < cards.count {
            currentCard = shuffledCards[currentIndex]
            toggleFlip()
        } else {
            isFinished = true
        }
    }
    
    private func toggleFlip() {
        isFlipped.toggle()
    }
    
    // TODO: Fix this re-declaration
    private func updateCardLastSeen(card: Card) {
        viewContext.perform {
            // Modify the properties of the fetched object.
            card.dateLastSeen = Date()
            
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
        ReviewView()
    }
}
