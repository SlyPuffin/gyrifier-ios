//
//  CustomButtonView.swift
//  gyrifier
//
//  Created by   on 3/30/23.
//

import SwiftUI

enum CustomButtonSize {
    case normal, large, half_height, double_width
}

enum CustomButtonStyle {
    case normal, prominent, cancel
}

// Defaults: buttonStyle, fontWeight
extension CustomButtonView {
  init(_ label: String, buttonSize: CustomButtonSize, screenSize: CGSize) {
      self.init(label, buttonSize: buttonSize, screenSize: screenSize, buttonStyle: CustomButtonStyle.normal, fontWeight: .regular)
  }
}

// Defaults: buttonStyle
extension CustomButtonView {
    init(_ label: String, buttonSize: CustomButtonSize, screenSize: CGSize, fontWeight: Font.Weight) {
      self.init(label, buttonSize: buttonSize, screenSize: screenSize, buttonStyle: CustomButtonStyle.normal, fontWeight: fontWeight)
  }
}

// Defaults: fontWeight
extension CustomButtonView {
    init(_ label: String, buttonSize: CustomButtonSize, screenSize: CGSize, buttonStyle: CustomButtonStyle) {
        self.init(label, buttonSize: buttonSize, screenSize: screenSize, buttonStyle: buttonStyle, fontWeight: .regular)
  }
}


struct CustomButtonView: View {
    let label: String
    let buttonSize: CustomButtonSize
    let screenSize: CGSize
    let buttonStyle: CustomButtonStyle
    let fontWeight: Font.Weight
    
    init(_ label: String, buttonSize: CustomButtonSize, screenSize: CGSize, buttonStyle: CustomButtonStyle, fontWeight: Font.Weight) {
        self.label = label
        self.buttonSize = buttonSize
        self.screenSize = screenSize
        self.buttonStyle = buttonStyle
        self.fontWeight = fontWeight
    }
    
    var body: some View {
        Text(label)
            .font(calculateFont())
            .fontDesign(calculateFontDesign())
            .fontWeight(fontWeight)
            .padding(calculatePadding())
            .frame(width: calculateButtonWidth(screenSize: screenSize), height: calculateButtonHeight(screenSize: screenSize))
            .foregroundColor(calculateForegroundColor())
            .background(calculateBackgroundColor())
            .cornerRadius(calculateRadius())
            .overlay(
                RoundedRectangle(cornerRadius: calculateRadius())
                    .stroke(calculateBorderColor(), lineWidth: 2)
            )
    }
    
    // FIXME: This is confusing
    private func calculateFont() -> Font {
        var font: Font = .body
        if buttonStyle == .prominent {
            font = .title2
        }
        if buttonSize == .double_width {
            font = .title
        }
        return font
    }

    private func calculateFontDesign() -> Font.Design {
        var fontDesign: Font.Design
        switch buttonStyle {
        case .normal:
            fontDesign = .default
        case .prominent:
            fontDesign = .serif
        case .cancel:
            fontDesign = .default
        }
        return fontDesign
    }
    
    private func calculateBackgroundColor() -> Color {
        var color: Color
        switch buttonStyle {
        case .normal:
            color = .blue
        case .prominent:
            color = .blue
        case .cancel:
            color = .clear
        }
        return color
    }
    
    private func calculateForegroundColor() -> Color {
        var color: Color
        switch buttonStyle {
        case .normal:
            color = .white
        case .prominent:
            color = .white
        case .cancel:
            color = .blue
        }
        return color
    }
    
    private func calculateBorderColor() -> Color {
        var color: Color
        switch buttonStyle {
        case .normal:
            color = .clear
        case .prominent:
            color = .clear
        case .cancel:
            color = .blue
        }
        return color
    }
    
    private func calculateButtonWidth(screenSize: CGSize) -> CGFloat {
        var width: CGFloat = 0
        switch buttonSize {
        case .normal:
            width = screenSize.width / 5.0
        case .large:
            width = screenSize.width / 3.0
        case .half_height:
            width = screenSize.width / 3.0
        case .double_width:
            width = screenSize.width / 1.5 + 10
        }
        return width
    }
    
    private func calculateButtonHeight(screenSize: CGSize) -> CGFloat {
        var height: CGFloat = 0
        switch buttonSize {
        case .normal:
            height = screenSize.height / 10.0
        case .large:
            height = screenSize.height / 6.0
        case .half_height:
            height = screenSize.height / 12.0 - 5.0
        case .double_width:
            height = screenSize.height / 6.0

        }
        return height
    }
    
    private func calculatePadding() -> CGFloat {
        var padding: CGFloat = 0
        switch buttonSize {
        case .normal:
            padding = 4.0
        case .large:
            padding = 8.0
        case .half_height:
            padding = 4.0
        case .double_width:
            padding = 8.0
        }
        return padding
    }
    
    private func calculateRadius() -> CGFloat {
        var radius: CGFloat = 0
        switch buttonSize {
        case .normal:
            radius = 4.0
        case .large:
            radius = 8.0
        case .half_height:
            radius = 4.0
        case .double_width:
            radius = 8.0
        }
        return radius
    }
}

struct CustomButtonView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            CustomButtonView("Custom Button", buttonSize: .large, screenSize: geo.size, buttonStyle: .cancel)
        }
    }
}
