//
//  SubscriptionView.swift
//  FlowTale
//
//  Created by iakalann on 13/12/2024.
//

import StoreKit
import SwiftUI

struct SubscriptionView: View {
    @EnvironmentObject var store: FlowTaleStore

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text(store.state.subscriptionState.isSubscribed ? LocalizedString.manageSubscription : LocalizedString.subscribe)
                .font(.flowTaleHeader())
                .bold()
                .foregroundColor(.ftPrimary)
            if !store.state.subscriptionState.isSubscribed {
                Text(LocalizedString.subscriptionSubscribeNow)
                    .multilineTextAlignment(.center)
                    .font(.flowTaleSecondaryHeader())
                    .bold()
                    .foregroundColor(.ftPrimary)
            }

            ForEach(store.state.subscriptionState.products?.sorted(by: { $0.price > $1.price }) ?? []) { product in
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
                                                  store.dispatch(.subscriptionAction(.validateReceipt))
                                                  // Then attempt to purchase
                                                  store.dispatch(.subscriptionAction(.purchaseSubscription(product)))
                                              }
                                          })
            }

            VStack {
                Text(LocalizedString.free)
                    .font(.flowTaleHeader())
                    .bold()
                Text(LocalizedString.subscriptionFreeCharactersDetail(4000))
                    .font(.flowTaleSecondaryHeader())
            }
            .foregroundStyle(.ftPrimary)

            Divider()

            Button {
                Task {
                    store.dispatch(.subscriptionAction(.validateReceipt))
                    store.dispatch(.subscriptionAction(.restoreSubscriptions))
                }
            } label: {
                Text(LocalizedString.restoreSubscription)
                    .multilineTextAlignment(.center)
                    .font(.flowTaleSecondaryHeader())
                    .bold()
                    .foregroundColor(.ftPrimary)
            }

            HStack {
                Button {
                    if let url = URL(string: "https://www.smileydude.co.uk/post/flowtale-terms-of-use-eula") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                } label: {
                    Text(LocalizedString.termsOfUse)
                        .multilineTextAlignment(.center)
                        .font(.flowTaleSecondaryHeader())
                        .foregroundColor(.ftPrimary)
                }

                Button {
                    if let url = URL(string: "https://www.smileydude.co.uk/post/flowtale-privacy-policy") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                } label: {
                    Text(LocalizedString.privacyPolicy)
                        .multilineTextAlignment(.center)
                        .font(.flowTaleSecondaryHeader())
                        .foregroundColor(.ftPrimary)
                }
            }

            if store.state.subscriptionState.isSubscribed {
                Text(LocalizedString.manageSubscriptionsInstructions)
                    .multilineTextAlignment(.center)
                    .font(.flowTaleSecondaryHeader())
                    .foregroundColor(.ftPrimary)
            }
        }
        // Validate receipt whenever subscription view appears to ensure we handle sandbox receipts properly
        .onAppear {
            Task {
                store.dispatch(.subscriptionAction(.validateReceipt))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ftBackground)
        .navigationTitle(ContentTab.subscribe.title)
        .navigationBarTitleDisplayMode(.inline)
        .overlay(content: {
            Group {
                if store.state.subscriptionState.isLoadingSubscriptionPurchase {
                    ZStack {
                        Color.black.opacity(0.5)
                        ProgressView()
                            .tint(.ftPrimary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        })
    }
}

enum SubscriptionLevel: CaseIterable {
    case level1, level2

    var ssmlCharacterLimitPerDay: Int {
        switch self {
        case .level1:
            15000
        case .level2:
            30000
        }
    }
    

    var idString: String {
        switch self {
        case .level1:
            "com.flowtale.level_1"
        case .level2:
            "com.flowtale.level_2"
        }
    }

    init?(id: String) {
        guard let level = SubscriptionLevel.allCases.first(where: { $0.idString == id }) else {
            return nil
        }
        self = level
    }
}
