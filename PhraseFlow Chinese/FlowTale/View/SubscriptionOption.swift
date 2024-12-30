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
        Button(action: {
            if product != nil {
                action()
            }
        }, label: {
            VStack {
                Text(title)
                    .font(.title2)
                    .bold()
                Text(detail)
                    .font(.subheadline)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(product == nil ? FlowTaleColor.secondary : FlowTaleColor.accent)
            .foregroundColor(product == nil ? FlowTaleColor.primary : FlowTaleColor.background)
            .cornerRadius(10)
        })
    }
}
