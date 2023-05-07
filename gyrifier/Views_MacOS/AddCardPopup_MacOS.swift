//
//  AddCardPopup_MacOS.swift
//  gyrifier-macos
//
//  Created by   on 4/7/23.
//

import SwiftUI

struct AddCardPopup_MacOS: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    let savedText = "Card added to deck!"
    @State var errorText = "Please input text for both the front and back of the card."
    @State var cardFrontText = ""
    @State var cardBackText = ""
    @State var isError = false
    @State var isSaved = false

    var body: some View {
        HStack {
            Button {
                self.presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Back")
                    .buttonStyle(.borderedProminent)
            }
            .padding()
            Spacer()
            Button("Save Card", action: saveNewCard)
                .buttonStyle(.plain)
                .padding(1)
                .frame(width: 80, height: 20)
                .background(.blue)
                .foregroundColor(.white)
                .cornerRadius(3)
                .padding()
        }
        .padding(.bottom)
        VStack {
            if (isError || isSaved) {
                Text(isError ? errorText : savedText)
                    .foregroundColor(isError ? .red : .green)
            }
            Text("Card Front")
            TextEditor(text: $cardFrontText)
                .multilineTextAlignment(.center)
                .overlay(
                         RoundedRectangle(cornerRadius: 2)
                           .stroke(Color.blue, lineWidth: 2)
                         )
                .padding(.bottom)
                .padding(.horizontal, 30)
            Text("Card Back")
                .padding(.top)
            TextEditor(text: $cardBackText)
                .multilineTextAlignment(.center)
                .overlay(
                         RoundedRectangle(cornerRadius: 2)
                           .stroke(Color.blue, lineWidth: 2)
                         )
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
        }
        .padding(.bottom)
    }
    
    // TODO: Fix re-declaration here, too
    private func saveNewCard() {
        if (cardFrontText.isEmpty || cardBackText.isEmpty) {
            isError = true
            errorText = "Please input text for both the front and back of the card."
        } else {
            let newCard = Card(context: viewContext)
            newCard.dateCreated = Date()
            newCard.dateUpdated = Date()
            newCard.nextAppearance = Date()
            newCard.dateLastSeen = Date(timeIntervalSinceReferenceDate: 0)
            newCard.level = 1
            newCard.timesSeen = 0
            newCard.avgTimeSpent = 0.0
            newCard.cardFront = cardFrontText
            newCard.cardBack = cardBackText
            newCard.cardHint = ""

            do {
                try viewContext.save()
                isError = false
                isSaved = true
                cardFrontText = ""
                cardBackText = ""
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                isError = true
                errorText = "Failed to create new card. Please try again."
            }
        }
    }
}

struct AddCardPopup_MacOS_Previews: PreviewProvider {
    static var previews: some View {
        AddCardPopup_MacOS().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .frame(width: 500, height: 400)
    }
}
