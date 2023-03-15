//
//  DetailView.swift
//  gyrifier
//
//  Created by   on 3/6/23.
//

import SwiftUI

// TODO:
// 1) Check for empty entries on save
// 2) Fix Double display for time spent
// 3) Display "min" and "sec" appropriately based on time
// 4) Add selector for category
// 5) Filter by category in edit view

// TODO: Fix this re-declaration
private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct DetailView: View {
    @Environment(\.managedObjectContext) private var viewContext

    let currentCard: Card
    @State var isEditMode = false
    @State var cardFront = ""
    @State var cardBack = ""
    @State var cardHint = ""
    
    var body: some View {
        VStack {
            if (isEditMode) {
                HStack {
                    Text("Card Front")
                    TextField("\(currentCard.cardFront!)", text: $cardFront)
                }
                HStack {
                    Text("Card Back")
                    TextField("\(currentCard.cardBack!)", text: $cardBack)
                }
                HStack {
                    Text("Card Hint")
                    TextField("\(currentCard.cardHint!)", text: $cardHint)
                }
                Text("Category: \(currentCard.category ?? "" )")
                Text("Level: \(currentCard.level)")
                Text("Last Seen: \(currentCard.dateLastSeen!, formatter: itemFormatter)")
                Text("Times Seen: \(currentCard.timesSeen)")
                Text("Average Time Spent: \(currentCard.avgTimeSpent) seconds")
                Text("Created: \(currentCard.dateCreated!, formatter: itemFormatter)")
                Text("Updated: \(currentCard.dateUpdated!, formatter: itemFormatter)")
            } else {
                Text("Card Front: \(currentCard.cardFront!)")
                Text("Card Back: \(currentCard.cardBack!)")
                Text("Card Hint: \(currentCard.cardHint!)")
                Text("Category: \(currentCard.category ?? "" )")
                Text("Level: \(currentCard.level)")
                Text("Last Seen: \(currentCard.dateLastSeen!, formatter: itemFormatter)")
                Text("Times Seen: \(currentCard.timesSeen)")
                Text("Average Time Spent: \(currentCard.avgTimeSpent) seconds")
                Text("Created: \(currentCard.dateCreated!, formatter: itemFormatter)")
                Text("Updated: \(currentCard.dateUpdated!, formatter: itemFormatter)")
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if (isEditMode) {
                    Button(action: saveCard) {
                        Label("Save", systemImage: "square.and.arrow.down")
                    }
                }
            }
            ToolbarItem {
                Button(action: editCard) {
                    if (isEditMode) {
                        Label("Cancel", systemImage: "xmark.circle.fill")
                    } else {
                        Label("Edit Card", systemImage: "pencil.circle")
                    }
                }
            }
        }
    }
    
    private func editCard() {
        isEditMode.toggle()
    }
    
    // TODO: Fix this re-declaration
    private func saveCard() {
        viewContext.perform {
            // Modify the properties of the fetched object.
            currentCard.dateCreated = currentCard.dateCreated
            currentCard.dateUpdated = Date()
            currentCard.dateLastSeen = currentCard.dateLastSeen
            currentCard.cardFront = cardFront
            currentCard.cardBack = cardBack
            currentCard.cardHint = cardHint
            
            do {
                // Save the context to persist the changes.
                try viewContext.save()
                DispatchQueue.main.async {
                    editCard()
                }
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        let currentCard = Card()
        DetailView(currentCard: currentCard).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
