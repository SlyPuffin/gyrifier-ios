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
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.dateCreated, ascending: true)],
        animation: .default)
    private var cards: FetchedResults<Card>
    
    @State var isPressed = false
    @State var isLevelUpAvailable = false
    @State var isReviewPopupOpened = false
    @State var isAddPopupOpened = false
    @State var isEditPopupOpened = false
    @State var isLevelUpPopupOpened = false
    
    var body: some View {
        GeometryReader { geometryReader in
            VStack (alignment: .center, spacing: 10) {
                Spacer()
                HStack (alignment: .center) {
                    Spacer()
                    ZStack {
                        Text("Gyrifier")
                            .font(.largeTitle)
                            .fontWeight(.thin)
                            .fontDesign(.serif)
                            .opacity(isPressed ? 1 : 0)
                            .animation(Animation.easeInOut(duration: isPressed ? 0.2 : 0.0), value: isPressed)
                        Button {
                            withAnimation {
                                isPressed.toggle()
                            }
                        } label: {
                            CustomButtonView("Gyrifier", buttonSize: isPressed ? .half_height : .large, screenSize: geometryReader.size, buttonStyle: .prominent, fontWeight: .thin)
                        }
                        .opacity(isPressed ? 0 : 1)
                        .buttonStyle(.plain)
                        .animation(Animation.easeIn(duration: isPressed ? 0.0 : 0.6), value: isPressed)
                    }
                    Spacer()
                }
                if isPressed {
                    HStack (alignment: .center, spacing: 10) {
                        Spacer()
                        Button {
                            self.isReviewPopupOpened.toggle()
                        } label: {
                            CustomButtonView("Review", buttonSize: isLevelUpAvailable ? .large : .double_width, screenSize: geometryReader.size, fontWeight: .medium)
                        }
                        .buttonStyle(.plain)
                        if isLevelUpAvailable {
                            Button {
                                self.isLevelUpPopupOpened.toggle()
                            } label: {
                                CustomButtonView("Level Up", buttonSize: .large, screenSize: geometryReader.size)
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer()
                    }
                    .opacity(isPressed ? 1 : 0)
                    .animation(Animation.easeInOut(duration: 0.2), value: isPressed)
                    HStack (alignment: .center, spacing: 10) {
                        VStack {
                            Button {
                                self.isAddPopupOpened.toggle()
                            } label: {
                                CustomButtonView("Add", buttonSize: .half_height, screenSize: geometryReader.size)
                            }
                            .buttonStyle(.plain)
                            Button {
                                self.isEditPopupOpened.toggle()
                            } label: {
                                CustomButtonView("Edit", buttonSize: .half_height, screenSize: geometryReader.size)
                            }
                            .buttonStyle(.plain)
                        }
                        VStack {
                            Button {
                                // TODO: Implement
                            } label: {
                                CustomButtonView("Settings", buttonSize: .half_height, screenSize: geometryReader.size)
                            }
                            .buttonStyle(.plain)
                            Button {
                                withAnimation {
                                    isPressed.toggle()
                                }
                            } label: {
                                CustomButtonView("Close", buttonSize: .half_height, screenSize: geometryReader.size, buttonStyle: .cancel, fontWeight: .medium)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .opacity(isPressed ? 1 : 0)
                    .animation(Animation.easeInOut(duration: 0.2), value: isPressed)
                    .onAppear() {
                        isLevelUpAvailable = checkForLevelUps(cards: Array(cards))
                    }
                }
                Spacer()
            }
            .sheet(isPresented: self.$isReviewPopupOpened) {
                #if os(iOS)
                ReviewPopup()
                    .environmentObject(navigator)
                #endif
                #if os(macOS)
                ReviewPopup_MacOS()
                    .environmentObject(navigator)
                    .frame(width: 300, height: 200)
                #endif
            }
            .sheet(isPresented: self.$isAddPopupOpened) {
                #if os(iOS)
                AddCardPopup()
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(navigator)
                #endif
                #if os(macOS)
                AddCardPopup_MacOS()
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(navigator)
                    .frame(width: geometryReader.size.width * 0.8, height: geometryReader.size.height * 0.6)
                #endif
            }
            .sheet(isPresented: self.$isEditPopupOpened) {
                #if os(iOS)
                EditPopup()
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(navigator)
                #endif
                #if os(macOS)
                EditPopup_MacOS()
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(navigator)
                    .frame(width: geometryReader.size.width * 0.8, height: geometryReader.size.height * 0.8)
                #endif
            }
            .sheet(isPresented: self.$isLevelUpPopupOpened) {
                #if os(iOS)
                LevelUpPopup(cards: returnLevelUps(cards: Array(cards)))
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(navigator)
                #endif
                #if os(macOS)
                LevelUpPopup_MacOS(cards: returnLevelUps(cards: Array(cards)))
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(navigator)
                    .frame(width: geometryReader.size.width * 0.8, height: geometryReader.size.height * 0.6)
                #endif
            }
        }
    }
    
    private func checkForLevelUps(cards: [Card]) -> Bool {
        return !cards.filter({canCardLevelUp(card: $0)}).isEmpty
    }
    
    private func returnLevelUps(cards: [Card]) -> [Card] {
        return cards.filter({canCardLevelUp(card: $0)}).shuffled()
    }

    private func canCardLevelUp(card: Card) -> Bool {
        return (card.level == 1 && card.experiencePoints == 3)
//        return ((card.level == 1 && card.experiencePoints == 3) || (card.level == 2 && card.experiencePoints == 8) || (card.level == 3 && card.experiencePoints == 15) || (card.level == 4 && card.experiencePoints == 25))
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
