//
//  FlashCardView.swift
//  gyrifier
//
//  Created by   on 4/14/23.
//

import SwiftUI

struct FlashCardView: View {
    let text: String
    let backgroundColor: Color
    let header: String
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .center) {
                Text(header)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                Text(text)
                    .foregroundColor(.black)
                    .padding()
            }
        }
        .padding(30)
        .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(backgroundColor)
            )
        .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(getBorderColor(), lineWidth: 2)
            )

    }
    
    private func getForegroundColor() -> Color {
        return .black
    }

    private func getBorderColor() -> Color {
        return .black
    }
}

struct FlashCardView_Previews: PreviewProvider {
    static var previews: some View {
        FlashCardView(text: "Dummy Text", backgroundColor: .black, header: "Front")
    }
}
