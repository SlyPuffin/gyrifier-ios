//
//  ReviewView.swift
//  gyrifier
//
//  Created by   on 3/3/23.
//

import SwiftUI

struct ReviewView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var navigator: Navigator
    @StateObject private var model = ReviewViewModel()
    @State var isLevelUpPopupOpened = false

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.dateCreated, ascending: true)],
        animation: .default)
    private var cards: FetchedResults<Card>
    
    let timeLimit: Double
    
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
        if model.isFinished {
            VStack(alignment: .center) {
                if model.checkForLevelUps(cards: Array(cards)) {
                    HStack(alignment: .center) {
                        Text("Level up some cards?")
                    }
                    HStack(alignment: .center) {
                        Button {
                            self.isLevelUpPopupOpened.toggle()
                        } label: {
                            Text("Level Up!")
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                        Button {
                            navigator.changeView(nextView: .home)
                        } label: {
                            Text("No Thanks")
                        }
                        .buttonStyle(.borderless)
                        .padding()
                    }
                } else {
                    HStack(alignment: .center) {
                        Text("Congratulations! You finished!")
                    }
                }
            }
            .sheet(isPresented: self.$isLevelUpPopupOpened) {
                #if os(iOS)
                LevelUpPopup(cards: model.returnLevelUps(cards: Array(cards)))
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(navigator)
                #endif
                #if os(macOS)
                // TODO: Add geometry reader so we can use frame better here
                LevelUpPopup_MacOS(cards: model.returnLevelUps(cards: Array(cards)))
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(navigator)
                    .frame(width: 500, height: 400)
                #endif
            }
            Spacer()
        } else {
            Button {
                model.tapCard(viewContext: viewContext)
            } label: {
                FlashCardView(text: model.getCardContent(), backgroundColor: model.getCardBackgroundColor(), header: model.getCardHeader())
            }
            .buttonStyle(.plain)
            .onAppear() {
                // TODO: Merge some of these functions together
                model.prepareCards(cards: Array(cards))
                model.setTimeLimit(timeLimit: timeLimit)
                model.startTimer()
            }
            Spacer()
        }
    }
}

struct ReviewView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewView(timeLimit: 300.0)
    }
}
