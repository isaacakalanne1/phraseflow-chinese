//
//  SubscriptionOption.swift
//  SmileyDude
//
//  Created by iakalann on 07/07/2023.
//

import SwiftUI
import StoreKit

struct SubscriptionOption: View {
    @EnvironmentObject var store: FlowTaleStore

    let title: String
    let detail: String
    let product: Product?
    let action: () -> Void

    var isUserCurrentSubscription: Bool {
        product != nil && store.state.subscriptionState.currentSubscription?.idString == product?.id
    }

    var backgroundColor: Color {
        if let prod = product {
            if isUserCurrentSubscription {
                return FlowTaleColor.background
            } else {
                return FlowTaleColor.accent
            }
        } else {
            return FlowTaleColor.secondary
        }
    }

    var foregroundColor: Color {
        if let prod = product {
            if isUserCurrentSubscription {
                return FlowTaleColor.accent
            } else {
                return FlowTaleColor.background
            }
        } else {
            return FlowTaleColor.primary
        }
    }

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
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isUserCurrentSubscription ? FlowTaleColor.accent : .clear, lineWidth: 3)
            )
        })
    }
}
