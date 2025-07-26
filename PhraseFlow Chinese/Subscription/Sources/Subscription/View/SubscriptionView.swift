//
//  SubscriptionView.swift
//  FlowTale
//
//  Created by iakalann on 13/12/2024.
//

import Localization
import StoreKit
import SwiftUI
import FTFont
import FTColor

struct SubscriptionView: View {
    @EnvironmentObject var store: SubscriptionStore

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text(store.state.isSubscribed ? LocalizedString.manageSubscription : LocalizedString.subscribe)
                .font(FTFont.flowTaleHeader())
                .bold()
                .foregroundColor(FTColor.primary)
            if !store.state.isSubscribed {
                Text(LocalizedString.subscriptionSubscribeNow)
                    .multilineTextAlignment(.center)
                    .font(FTFont.flowTaleSecondaryHeader())
                    .bold()
                    .foregroundColor(FTColor.primary)
            }

            ForEach(store.state.products?.sorted(by: { $0.price > $1.price }) ?? []) { product in
                let limitString: String
                if let characterLimit = SubscriptionLevel(id: product.id)?.ssmlCharacterLimitPerDay {
                    // Use subscription_characters_per_day localization key
                    limitString = LocalizedString.subscriptionCharactersPerDay(characterLimit)
                } else {
                    limitString = product.displayName
                }
                return SubscriptionOption(title: LocalizedString.pricePerMonth(product.displayPrice),
                                          detail: limitString,
                                          product: product,
                                          action: {
                                              Task {
                                                  // First validate receipt to ensure proper sandbox handling
                                                  store.dispatch(.validateReceipt)
                                                  // Then attempt to purchase
                                                  store.dispatch(.purchaseSubscription(product))
                                              }
                                          })
            }

            VStack {
                Text(LocalizedString.free)
                    .font(FTFont.flowTaleHeader())
                    .bold()
                Text(LocalizedString.subscriptionFreeCharactersDetail(4000))
                    .font(FTFont.flowTaleSecondaryHeader())
            }
            .foregroundStyle(FTColor.primary)

            Divider()

            Button {
                Task {
                    store.dispatch(.validateReceipt)
                    store.dispatch(.restoreSubscriptions)
                }
            } label: {
                Text(LocalizedString.restoreSubscription)
                    .multilineTextAlignment(.center)
                    .font(FTFont.flowTaleSecondaryHeader())
                    .bold()
                    .foregroundColor(FTColor.primary)
            }

            HStack {
                Button {
                    if let url = URL(string: "https://www.smileydude.co.uk/post/flowtale-terms-of-use-eula") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                } label: {
                    Text(LocalizedString.termsOfUse)
                        .multilineTextAlignment(.center)
                        .font(FTFont.flowTaleSecondaryHeader())
                        .foregroundColor(FTColor.primary)
                }

                Button {
                    if let url = URL(string: "https://www.smileydude.co.uk/post/flowtale-privacy-policy") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                } label: {
                    Text(LocalizedString.privacyPolicy)
                        .multilineTextAlignment(.center)
                        .font(FTFont.flowTaleSecondaryHeader())
                        .foregroundColor(FTColor.primary)
                }
            }

            if store.state.isSubscribed {
                Text(LocalizedString.manageSubscriptionsInstructions)
                    .multilineTextAlignment(.center)
                    .font(FTFont.flowTaleSecondaryHeader())
                    .foregroundColor(FTColor.primary)
            }
        }
        // Validate receipt whenever subscription view appears to ensure we handle sandbox receipts properly
        .onAppear {
            Task {
                store.dispatch(.validateReceipt)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColor.background)
        .navigationBarTitleDisplayMode(.inline)
        .overlay(content: {
            Group {
                if store.state.isLoadingSubscriptionPurchase {
                    ZStack {
                        Color.black.opacity(0.5)
                        ProgressView()
                            .tint(FTColor.primary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        })
    }
}
