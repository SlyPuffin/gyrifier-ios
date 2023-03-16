//
//  ContentView.swift
//  gyrifier
//
//  Created by   on 2/23/23.
//

import SwiftUI
import CoreData

struct EditPopup: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.dateCreated, ascending: true)],
        animation: .default)
    private var cards: FetchedResults<Card>

    var body: some View {
        NavigationView {
            List {
                ForEach(cards) { card in
                    NavigationLink {
                        DetailView(currentCard: card)
                            .environment(\.managedObjectContext, viewContext)
                    } label: {
                        Text("\(card.cardFront!) \(card.dateCreated!, formatter: itemFormatter)")
                    }
                    .navigationTitle("Edit Deck")
                    .navigationBarTitleDisplayMode(.inline)
                }
                .onDelete(perform: deleteCards)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Back")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addCard) {
                        Label("Add Card", systemImage: "plus")
                    }
                }
            }
            Text("Select a card")
        }
    }

    // TODO: Fix re-declaration here, too
    private func addCard() {
        withAnimation {
            let newCard = Card(context: viewContext)
            newCard.dateCreated = Date()
            newCard.dateUpdated = Date()
            newCard.dateLastSeen = Date(timeIntervalSinceReferenceDate: 0)
            newCard.cardFront = "Card Front"
            newCard.cardBack = "Card Back"
            newCard.cardHint = ""

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteCards(offsets: IndexSet) {
        withAnimation {
            offsets.map { cards[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

// TODO: Fix this re-declaration
private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditPopup().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
