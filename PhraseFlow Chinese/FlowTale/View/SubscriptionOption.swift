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
            .background(product == nil ? Color.gray : Color.accentColor)
            .foregroundColor(product == nil ? Color.black : Color.white)
            .cornerRadius(10)
        })
    }
}
