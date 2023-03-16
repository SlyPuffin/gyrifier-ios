//
//  AddCardView.swift
//  gyrifier
//
//  Created by   on 3/6/23.
//

import SwiftUI

struct AddCardPopup: View {
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
                .buttonStyle(.borderedProminent)
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
                .hideKeyboardWhenTappedAround()
                .multilineTextAlignment(.center)
                .padding(.bottom)
                .padding(.horizontal)
            Text("Card Back")
                .padding(.top)
            TextEditor(text: $cardBackText)
                .hideKeyboardWhenTappedAround()
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
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
            newCard.dateLastSeen = Date(timeIntervalSinceReferenceDate: 0)
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

struct AddCardView_Previews: PreviewProvider {
    static var previews: some View {
        AddCardPopup().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
