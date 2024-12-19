//
//  SubscriptionOption.swift
//  SmileyDude
//
//  Created by iakalann on 07/07/2023.
//

import SwiftUI
import StoreKit

struct SubscriptionOption: View {
    let title: String
    let detail: String
    let product: Product?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Text(title)
                    .font(.title2)
                    .bold()
                Text(detail)
                    .font(.subheadline)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(product == nil ? Color.accentColor : Color.primary)
            .foregroundColor(product == nil ? Color.primary : Color.accentColor)
            .cornerRadius(10)
        }
        .disabled(product == nil)
    }
}
