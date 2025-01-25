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
            let product = store.state.subscriptionState.products?.first
            Spacer()
            Text(store.state.subscriptionState.isSubscribed ? LocalizedString.manageSubscription : LocalizedString.subscribe)
                .font(.title)
                .bold()
                .foregroundColor(FlowTaleColor.primary)
            if !store.state.subscriptionState.isSubscribed {
                Text(LocalizedString.subscribeNowUnlimitedChapters)
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(FlowTaleColor.primary)
            }


            ForEach(store.state.subscriptionState.products?.sorted(by: { $0.price > $1.price }) ?? []) { product in
                SubscriptionOption(title: product.displayName,
                                   detail: LocalizedString.pricePerMonth(product.displayPrice),
                                   product: product,
                                   action: {
                    Task {
                        store.dispatch(.purchaseSubscription(product))
                    }
                    store.dispatch(.setSubscriptionSheetShowing(false))
                })
            }

            // TODO: Localize
            SubscriptionOption(title: LocalizedString.free, detail: "4 free chapters", product: nil, action: { })

            Button {
                Task {
                    store.dispatch(.restoreSubscriptions)
                    store.dispatch(.setSubscriptionSheetShowing(false))
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
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FlowTaleColor.background)
        .navigationTitle(LocalizedString.subscribe)
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension String {
    var subscriptionLevel: SubscriptionLevel? {
        switch self {
        case "com.flowtale.level_1":
                .level1
        case "com.flowtale.level_2":
                .level2
        case "com.flowtale.level_3":
                .level3
        default:
            nil
        }
    }
}

enum SubscriptionLevel {
    case level1, level2, level3, max

    var chapterLimitPerDay: Int {
        switch self {
        case .level1:
            3
        case .level2:
            6
        case .level3:
            10
        case .max:
            9999999
        }
    }
}
