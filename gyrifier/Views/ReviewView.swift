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
                HStack(alignment: .center) {
                    Text("Congratulations! You finished!")
                }
            }
            Spacer()
        } else {
            Button {
                if model.isFlipped {
                    model.iterateCards(viewContext: viewContext)
                } else {
                    model.toggleFlip()
                }
            } label: {
                HStack(alignment: .center) {
                    VStack(alignment: .center) {
                        if model.isFlipped {
                            Text("Back")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            if model.isLoading {
                                Text("Loading...")
                                    .padding()
                            } else {
                                Text(model.currentCard.cardBack ?? "Loading..")
                                    .foregroundColor(.white)
                                    .padding()
                            }
                        } else {
                            Text("Front")
                                .fontWeight(.bold)
                            if model.isLoading {
                                Text("Loading...")
                                    .padding()
                            } else {
                                Text(model.currentCard.cardFront ?? "Loading..")
                                    .padding()
                            }
                        }
                    }
                }
                .padding(30)
                .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(model.isFlipped ? .blue : .clear)
                    )
                .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.blue, lineWidth: 2)
                    )
            }
            .onAppear() {
                startIteration()
                model.setTimeLimit(timeLimit: timeLimit)
                model.startTimer()
            }
            Spacer()
        }
    }
    
    private func startIteration() {
        model.prepareCards(cards: cards.filter({isStudyDateToday($0.nextAppearance!)}).shuffled())
    }
        
    private func isStudyDateToday(_ date: Date) -> Bool {
        // TODO: Handle case where evening time practice doesn't spill into next day
        return date.timeIntervalSinceNow.sign == FloatingPointSign.minus
    }
}

struct ReviewView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewView(timeLimit: 300.0)
    }
}
