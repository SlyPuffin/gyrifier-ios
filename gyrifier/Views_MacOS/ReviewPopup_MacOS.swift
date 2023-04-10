//
//  ReviewPopup_MacOS.swift
//  gyrifier-macos
//
//  Created by   on 4/7/23.
//

import SwiftUI
import Combine

enum ReviewTime: Hashable {
    case none(String, Double)
    case custom(String, Double)
    case one(String, Double)
    case three(String, Double)
    case five(String, Double)
    case ten(String, Double)
}

enum CustomTimeUnit: String, CaseIterable, Identifiable {
    case seconds, minutes
    var id: Self { self }
}

struct ReviewPopup_MacOS: View {
    private let customNumbers = [Int](0..<60)
    private let options = [
        ReviewTime.none("None", -1.0),
        ReviewTime.custom("Custom", 0.0),
        ReviewTime.one("1 min", 60.0),
        ReviewTime.three("3 min", 180.0),
        ReviewTime.five("5 min", 300.0),
        ReviewTime.ten("10 min", 600.0),
    ]
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var navigator: Navigator
    
    @State private var selectedReviewTime: ReviewTime = .five("5 min", 300.0)
    @State private var selectedCustomTimeUnit: CustomTimeUnit = .minutes
    @State private var customTime = 5
    
    var body: some View {
        HStack {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Back")
            }
            .buttonStyle(.borderless)
            .padding()
            Spacer()
            Button {
                let timeLimit = calculateReviewTime()
                navigateToReview(reviewTime: timeLimit)
            } label: {
                Text("Start")
            }
            .buttonStyle(.plain)
            .padding(1)
            .frame(width: 40, height: 20)
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(3)
            .padding()
        }
        .padding(.bottom)
        VStack {
            Text("How long would you like to review?")
            Picker("Review Time", selection: $selectedReviewTime) {
                ForEach(options, id: \.self) { option in
                    Text("\(optionString(option))")
                        .tag(option)
                }
            }
            .pickerStyle(.menu)
            if optionString(selectedReviewTime) == "Custom" {
                HStack(spacing: 0) {
                    Picker(selection: $customTime, label: Text("")) {
                        ForEach(self.customNumbers, id: \.self) { index in
                            Text("\(index)").tag(index)
                       }
                    }
                    .pickerStyle(.menu)
                    .frame(minWidth: 0)
                    .compositingGroup()
                    .clipped()
                    Picker("", selection: $selectedCustomTimeUnit) {
                        Text("seconds").tag(CustomTimeUnit.seconds)
                        Text("minutes").tag(CustomTimeUnit.minutes)
                    }
                    .pickerStyle(.segmented)
                    .frame(minWidth: 0)
                    .compositingGroup()
                    .clipped()
                }
                .padding(.top)
            }
            Spacer()
        }
        .padding(.horizontal)
    }
    
    
    private func calculateReviewTime() -> Double{
        var timeLimit: Double = optionDouble(selectedReviewTime)
        /// Check if timeLimit is set to "Custom" (0.0)
        if optionString(selectedReviewTime) == "Custom" {
            let customOperator: Double = selectedCustomTimeUnit == .minutes ? 60.0 : 1.0
            timeLimit = Double(customTime) * customOperator
        }
        return timeLimit
    }
    
    private func navigateToReview(reviewTime: Double) {
        navigator.changeViewToReview(timeLimit: reviewTime)
    }
    
    private func optionString(_ option: ReviewTime) -> String {
        switch option {
        case .none(let str, _):
            return str
        case .custom(let str, _):
            return str
        case .one(let str, _):
            return str
        case .three(let str, _):
            return str
        case .five(let str, _):
            return str
        case .ten(let str, _):
            return str
        }
    }
    
    private func optionDouble(_ option: ReviewTime) -> Double {
        switch option {
        case .none(_, let dbl):
            return dbl
        case .custom(_, let dbl):
            return dbl
        case .one(_, let dbl):
            return dbl
        case .three(_, let dbl):
            return dbl
        case .five(_, let dbl):
            return dbl
        case .ten(_, let dbl):
            return dbl
        }
    }
}

struct ReviewPopup_MacOS_Previews: PreviewProvider {
    static var previews: some View {
        ReviewPopup_MacOS()
            .frame(width: 300, height: 200)
    }
}
