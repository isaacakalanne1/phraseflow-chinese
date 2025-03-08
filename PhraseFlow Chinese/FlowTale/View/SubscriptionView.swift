//
//  SubscriptionView.swift
//  FlowTale
//
//  Created by iakalann on 13/12/2024.
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @EnvironmentObject var store: FlowTaleStore

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text(store.state.subscriptionState.isSubscribed ? LocalizedString.manageSubscription : LocalizedString.subscribe)
                .font(.title)
                .bold()
                .foregroundColor(FlowTaleColor.primary)
            if !store.state.subscriptionState.isSubscribed {
                Text(LocalizedString.subscriptionSubscribeNow)
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(FlowTaleColor.primary)
            }

            ForEach(store.state.subscriptionState.products?.sorted(by: { $0.price > $1.price }) ?? []) { product in
                let chapterLimitString: String
                if let chapterLimit = SubscriptionLevel(id: product.id)?.chapterLimitPerDay {
                    chapterLimitString = LocalizedString.subscriptionChaptersPerDay(chapterLimit)
                } else {
                    chapterLimitString = product.displayName
                }
                return SubscriptionOption(title: chapterLimitString,
                                          detail: LocalizedString.pricePerMonth(product.displayPrice),
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

            SubscriptionOption(title: LocalizedString.free, detail: LocalizedString.subscriptionFreeChaptersDetail(4), product: nil, action: { })
                .disabled(true)

            Button {
                Task {
                    // First validate receipt to ensure proper sandbox handling
                    store.dispatch(.validateReceipt)
                    // Then restore purchases
                    store.dispatch(.restoreSubscriptions)
                }
            } label: {
                Text(LocalizedString.restoreSubscription)
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(FlowTaleColor.primary)
            }

            HStack {
                Button {
                    if let url = URL(string: "https://www.smileydude.co.uk/post/flowtale-terms-of-use-eula") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                } label: {
                    Text(LocalizedString.termsOfUse)
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .foregroundColor(FlowTaleColor.primary)
                }

                Button {
                    if let url = URL(string: "https://www.smileydude.co.uk/post/flowtale-privacy-policy") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                } label: {
                    Text(LocalizedString.privacyPolicy)
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .foregroundColor(FlowTaleColor.primary)
                }
            }

            if store.state.subscriptionState.isSubscribed {
                Text(LocalizedString.manageSubscriptionsInstructions)
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .foregroundColor(FlowTaleColor.primary)
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
        .background(FlowTaleColor.background)
        .navigationTitle(ContentTab.subscribe.title)
        .navigationBarTitleDisplayMode(.inline)
        .overlay(content: {
            Group {
                if store.state.subscriptionState.isLoadingSubscriptionPurchase {
                    ZStack {
                        Color.black.opacity(0.5)
                        ProgressView()
                            .tint(FlowTaleColor.primary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        })
    }
}

enum SubscriptionLevel: CaseIterable {
    case level1, level2

    var chapterLimitPerDay: Int {
        switch self {
        case .level1:
            10
        case .level2:
            20
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
