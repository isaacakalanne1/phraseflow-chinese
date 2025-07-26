//
//  SubscriptionOption.swift
//  SmileyDude
//
//  Created by iakalann on 07/07/2023.
//

import StoreKit
import SwiftUI
import FTFont
import FTColor

struct SubscriptionOption: View {
    @EnvironmentObject var store: SubscriptionStore

    let title: String
    let detail: String
    let product: Product?
    let action: () -> Void

    var isUserCurrentSubscription: Bool {
        product != nil && store.state.currentSubscription?.idString == product?.id
    }

    var backgroundColor: Color {
        if let _ = product {
            if isUserCurrentSubscription {
                return FTColor.primary
            } else {
                return FTColor.accent
            }
        } else {
            return FTColor.secondary
        }
    }

    var foregroundColor: Color {
        if let _ = product {
            if isUserCurrentSubscription {
                return FTColor.accent
            } else {
                return FTColor.background
            }
        } else {
            return FTColor.primary
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
                    .font(FTFont.flowTaleHeader())
                    .bold()
                Text(detail)
                    .font(FTFont.flowTaleSecondaryHeader())
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
