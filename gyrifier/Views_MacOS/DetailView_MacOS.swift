//
//  DetailView_MacOS.swift
//  gyrifier-macos
//
//  Created by   on 4/7/23.
//

import SwiftUI

// TODO:
// X) Check for empty entries on save
// X) Fix Double display for time spent
// X) Display "min" and "sec" appropriately based on time
// 4) Add selector for category
// 5) Filter by category in edit view

// TODO: Fix this re-declaration
private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct DetailView_MacOS: View {
    @Environment(\.managedObjectContext) private var viewContext

    let currentCard: Card
    @State var isEditMode = false
    @State var cardFront = ""
    @State var cardBack = ""
    @State var cardHint = ""
    @State var isError = false
    @State var errorText = "Please input text for both the front and back of the card."
    
    
    var body: some View {
        VStack {
            if isError {
                Text(errorText)
                    .foregroundColor(.red)
            }
        }
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
                VStack {
                    Text("Level: \(currentCard.level)")
                    Text("XP: \(currentCard.experiencePoints)")
                }
                Text("Next Appearance: \(currentCard.nextAppearance ?? Date(), formatter: itemFormatter)")
                VStack {
                    Text("Last Seen: \(currentCard.dateLastSeen!, formatter: itemFormatter)")
                    Text("# of Times Seen: \(currentCard.timesSeen)")
                    Text("Average Time Spent: \(displayTime(time: currentCard.avgTimeSpent))")
                }
                Text("Created: \(currentCard.dateCreated!, formatter: itemFormatter)")
                Text("Updated: \(currentCard.dateUpdated!, formatter: itemFormatter)")
            } else {
                Text("Card Front: \(currentCard.cardFront!)")
                Text("Card Back: \(currentCard.cardBack!)")
                Text("Card Hint: \(currentCard.cardHint!)")
                Text("Category: \(currentCard.category ?? "" )")
                VStack {
                    Text("Level: \(currentCard.level)")
                    Text("XP: \(currentCard.experiencePoints)")
                }
                Text("Next Appearance: \(currentCard.nextAppearance ?? Date(), formatter: itemFormatter)")
                VStack {
                    Text("Last Seen: \(currentCard.dateLastSeen!, formatter: itemFormatter)")
                    Text("# of Times Seen: \(currentCard.timesSeen)")
                    Text("Average Time Spent: \(displayTime(time: currentCard.avgTimeSpent))")
                }
                Text("Created: \(currentCard.dateCreated!, formatter: itemFormatter)")
                Text("Updated: \(currentCard.dateUpdated!, formatter: itemFormatter)")
            }
        }
        .toolbar {
            ToolbarItem {
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
        if cardFront.isEmpty {
            cardFront = currentCard.cardFront ?? ""
        }
        if cardBack.isEmpty {
            cardBack = currentCard.cardBack ?? ""
        }
        isEditMode.toggle()
    }
    
    private func displayTime(time: Double) -> String {
        if time == 0.0 {
            return "0 sec"
        }
        let sec = Int(time.truncatingRemainder(dividingBy: 60.0))
        let min = Int(time) / 60
        var outputString = ""
        if sec > 0 {
            outputString = "\(sec) sec"
            if min > 0 {
                outputString.append(" ")
            }
        }
        if min > 0 {
            outputString.append("\(min) min")
        }
        return outputString
    }
    
    // TODO: Fix this re-declaration
    private func saveCard() {
        if (cardFront.isEmpty || cardBack.isEmpty) {
            isError = true
        } else {
            isError = false
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
}

struct DetailView_MacOS_Previews: PreviewProvider {
    static var previews: some View {
        let currentCard = Card()
        DetailView_MacOS(currentCard: currentCard).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
