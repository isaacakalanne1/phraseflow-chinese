//
//  SubscriptionOption.swift
//  SmileyDude
//
//  Created by iakalann on 07/07/2023.
//

import StoreKit
import SwiftUI

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
        if let _ = product {
            if isUserCurrentSubscription {
                return .ftPrimary
            } else {
                return FTColor.accent
            }
        } else {
            return .ftSecondary
        }
    }

    var foregroundColor: Color {
        if let _ = product {
            if isUserCurrentSubscription {
                return FTColor.accent
            } else {
                return .ftBackground
            }
        } else {
            return .ftPrimary
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
                    .font(.flowTaleHeader())
                    .bold()
                Text(detail)
                    .font(.flowTaleSecondaryHeader())
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isUserCurrentSubscription ? FTColor.accent : .clear, lineWidth: 3)
            )
        })
    }
}
