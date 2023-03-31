//
//  LevelUpPopup.swift
//  gyrifier
//
//  Created by   on 3/30/23.
//

import SwiftUI

struct LevelUpPopup: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var navigator: Navigator
    
    let savedText = "Card leveled up!"
    @State var errorText = "Please input new information for the card."
    @State var cardExpansionText = ""
    @State var isError = false
    @State var isSaved = false
    @State var isDialog = false
    @State var isFinished = false
    @State var iterator = 0
    
    var cards: [Card]

    var body: some View {
        VStack (alignment: .center, spacing: 25) {
            Spacer()
            if (isError || isSaved) {
                Text(isError ? errorText : savedText)
                    .foregroundColor(isError ? .red : .green)
                    .animation(Animation.easeOut(duration: isSaved ? 0.0 : 25.0), value: isSaved)
            }
            if (isFinished) {
                Text("No more cards to level up. Nice job!")
                Button {
                    closeLevelUpPopup()
                } label: {
                    Text("Back")
                }
                .buttonStyle(.borderless)
                .padding()
            } else if (isDialog) {
                Text("Level up another?")
                HStack(alignment: .center) {
                    Button {
                        isDialog = false
                    } label: {
                        Text("Level Up!")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    Button {
                        closeLevelUpPopup()
                    } label: {
                        Text("No Thanks")
                    }
                    .buttonStyle(.borderless)
                    .padding()
                }
            } else {
                VStack {
                    Text("Front")
                    Text(cards[iterator].cardFront ?? "")
                }
                VStack {
                    Text("Back")
                    Text(cards[iterator].cardBack ?? "")
                }
                VStack {
                    HStack {
                        Text("Expansion")
                            .padding(.horizontal)
                        Button("Save Card", action: saveLevelUpCard)
                            .buttonStyle(.borderedProminent)
                            .padding(.horizontal)
                    }
                    TextEditor(text: $cardExpansionText)
                        .hideKeyboardWhenTappedAround()
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                        .padding(.horizontal)
                }
            }
            Spacer()
        }
    }
    
    private func closeLevelUpPopup() {
        DispatchQueue.main.async {
            self.presentationMode.wrappedValue.dismiss()
        }
        if navigator.currentView != .home {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                navigator.changeView(nextView: .home)
            }
        }
    }
    
    private func iterateLevelUpCards() {
        iterator = iterator + 1
        if iterator >= cards.count {
            isFinished = true
        }
        cardExpansionText = ""
    }
    
    private func saveLevelUpCard() {
        if (cardExpansionText.isEmpty) {
            isError = true
        } else {
            viewContext.perform {
                // Modify the properties of the fetched object.
                cards[iterator].level = cards[iterator].level + 1
                cards[iterator].expansion_1 = cardExpansionText
                
                do {
                    // Save the context to persist the changes.
                    try viewContext.save()
                    isError = false
                    isSaved = true
                    isDialog = true
                    iterateLevelUpCards()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        withAnimation {
                            isSaved = false
                        }
                    }
                } catch {
                    //let nsError = error as NSError
                    isError = true
                    errorText = "Failed to create new card. Please try again."
                }
            }
        }
    }
}

struct LevelUpPopup_Previews: PreviewProvider {
    static var previews: some View {
        LevelUpPopup(cards: [Card(), Card()])
    }
}
