//
//  UITestView.swift
//  gyrifier
//
//  Created by   on 4/2/23.
//

import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

struct UITestView: View {
    var body: some View {
        HStack {
            VStack(alignment: .center) {
                Text("Level 1")
                FlashCardView(title: "Front", text: "Front side text goes here!", backgroundColor: 0xF1F9F9, borderColor: 0x000000, clear: false)
                FlashCardView(title: "Back", text: "Back side text goes here!", backgroundColor: 0xD4EDEC, borderColor: 0x000000, clear: false)
            }
            VStack(alignment: .center) {
                Text("Level 2")
                FlashCardView(title: "Front", text: "Front side text goes here!", backgroundColor: 0xF0F9F6, borderColor: 0x000000, clear: false)
                FlashCardView(title: "Expansion", text: "Expansion side text goes here!", backgroundColor: 0xE1F4ED, borderColor: 0x000000, clear: false)
                FlashCardView(title: "Back", text: "Back side text goes here!", backgroundColor: 0xB6E2D3, borderColor: 0x000000, clear: false)
            }
            VStack(alignment: .center) {
                Text("Level 3")
                FlashCardView(title: "Front", text: "Front side text goes here!", backgroundColor: 0xEAF1FD, borderColor: 0x000000, clear: false)
                FlashCardView(title: "Expansion 2", text: "2nd Expansion side text goes here!", backgroundColor: 0xD7E3FC, borderColor: 0x000000, clear: false)
                FlashCardView(title: "Expansion", text: "Expansion side text goes here!", backgroundColor: 0xC1D3FE, borderColor: 0x000000, clear: false)
                FlashCardView(title: "Back", text: "Back side text goes here!", backgroundColor: 0xABC4FF, borderColor: 0x000000, clear: false)
            }
            VStack(alignment: .center) {
                Text("Level 4")
                FlashCardView(title: "Front", text: "Front side text goes here!", backgroundColor: 0xF1ECF9, borderColor: 0x000000, clear: false)
                FlashCardView(title: "Expansion 3", text: "2nd Expansion side text goes here!", backgroundColor: 0xE5D9F2, borderColor: 0x000000, clear: false)
                FlashCardView(title: "Expansion 2", text: "2nd Expansion side text goes here!", backgroundColor: 0xCDC1FF, borderColor: 0x000000, clear: false)
                FlashCardView(title: "Expansion", text: "Expansion side text goes here!", backgroundColor: 0xA594F9, borderColor: 0x000000, clear: false)
                FlashCardView(title: "Back", text: "Back side text goes here!", backgroundColor: 0x7371FC, borderColor: 0x000000, clear: false)
            }
        }
    }
}

struct FlashCardView: View {
    let title: String
    let text: String
    let backgroundColor: UInt
    let borderColor: UInt
    let clear: Bool
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .center) {
                Text(title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: borderColor))
                Text(text)
                    .foregroundColor(Color(hex: borderColor))
                    .padding()
            }
        }
        .padding(30)
        .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(clear ? .clear : Color(hex: backgroundColor))
            )
        .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(hex: borderColor), lineWidth: 2)
            )

    }
}


struct UITestView_Previews: PreviewProvider {
    static var previews: some View {
        UITestView()
    }
}
