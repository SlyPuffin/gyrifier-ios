//
//  HomeView.swift
//  gyrifier
//
//  Created by   on 3/3/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var navigator: Navigator
    
    @State var isPressed = false
    @State var isPopupOpened: Bool = false

    var body: some View {
        if isPressed {
            HStack (alignment: .center) {
                VStack (alignment: .center, spacing: 25) {
                    Text("The Deck")
                        .fontWeight(.bold)
                    Button {
                        self.isPopupOpened.toggle()
                    } label: {
                        Text("Review")
                    }
                    .buttonStyle(.borderedProminent)
                    Button {
                        navigator.changeView(nextView: .add)
                    } label: {
                        Text("Add")
                    }
                    .buttonStyle(.borderedProminent)
                    Button {
                        navigator.changeView(nextView: .edit)
                    } label: {
                        Text("Edit")
                    }
                    .buttonStyle(.borderedProminent)
                    Button("Close", action: togglePressed)
                        .buttonStyle(.bordered)
                }
            }
            .sheet(isPresented: self.$isPopupOpened) {
                HomePopup()
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
