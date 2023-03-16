//
//  HomeView.swift
//  gyrifier
//
//  Created by   on 3/3/23.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var navigator: Navigator
    
    @State var isPressed = false
    @State var isReviewPopupOpened = false
    @State var isAddPopupOpened = false
    @State var isEditPopupOpened = false

    var body: some View {
        if isPressed {
            HStack (alignment: .center) {
                VStack (alignment: .center, spacing: 25) {
                    Text("The Deck")
                        .fontWeight(.bold)
                    Button {
                        self.isReviewPopupOpened.toggle()
                    } label: {
                        Text("Review")
                    }
                    .buttonStyle(.borderedProminent)
                    Button {
                        self.isAddPopupOpened.toggle()
                    } label: {
                        Text("Add")
                    }
                    .buttonStyle(.borderedProminent)
                    Button {
                        self.isEditPopupOpened.toggle()
                    } label: {
                        Text("Edit")
                    }
                    .buttonStyle(.borderedProminent)
                    Button("Close", action: togglePressed)
                        .buttonStyle(.bordered)
                }
            }
            .sheet(isPresented: self.$isReviewPopupOpened) {
                ReviewPopup()
                    .environmentObject(navigator)
            }
            .sheet(isPresented: self.$isAddPopupOpened) {
                AddCardPopup()
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(navigator)
            }
            .sheet(isPresented: self.$isEditPopupOpened) {
                EditPopup()
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(navigator)
            }
        } else {
            VStack (alignment: .center) {
                HStack (alignment: .center) {
                    Button("The Deck", action: togglePressed)
                        .buttonStyle(.borderedProminent)
                }
            }
        }
    }
    
    private func togglePressed() {
        isPressed.toggle()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
