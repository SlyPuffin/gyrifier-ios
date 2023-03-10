//
//  HomeView.swift
//  gyrifier
//
//  Created by   on 3/3/23.
//

// TODO: 3/06
// - [x] Update "lastSeen" when flipping through cards
// - [x] Fix Navigation view nested stuff
// - [x] Plan/design the project a bit
// - [ ] Create new add card logic

import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.dateCreated, ascending: true)],
        animation: .default)
    private var cards: FetchedResults<Card>
    @State var isPressed = false

    var body: some View {
        if isPressed {
            NavigationView {
                HStack (alignment: .center) {
                    VStack (alignment: .center, spacing: 25) {
                        Text("The Deck")
                            .fontWeight(.bold)
                        NavigationLink {
                            ReviewView()
                                .environment(\.managedObjectContext, viewContext)
                        } label: {
                            Text("Review")
                        }
                        .navigationTitle("Gyrifier")
                        .navigationBarTitleDisplayMode(.large)
                        NavigationLink {
                            AddCardView()
                                .environment(\.managedObjectContext, viewContext)
                        } label: {
                            Text("Add")
                        }
                        .navigationTitle("Gyrifier")
                        .navigationBarTitleDisplayMode(.large)
                        NavigationLink {
                            EditView()
                                .environment(\.managedObjectContext, viewContext)
                        } label: {
                            Text("Edit")
                        }
                        .navigationTitle("Gyrifier")
                        .navigationBarTitleDisplayMode(.large)
                        Button("Close", action: togglePressed)
                            .buttonStyle(.borderedProminent)
                    }
                }
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
