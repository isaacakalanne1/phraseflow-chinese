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
                Text("Subscribe now to create more chapters") // TODO: Localize
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(FlowTaleColor.primary)

                Button {
                    store.dispatch(.showFreeLimitExplanationScreen(isShowing: true))
                } label: {
                    Text("Why is there a free trial limit?") // TODO: Localize
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .underline()
                        .foregroundColor(FlowTaleColor.primary)
                }
            }

            ForEach(store.state.subscriptionState.products?.sorted(by: { $0.price > $1.price }) ?? []) { product in
                SubscriptionOption(title: product.displayName,
                                   detail: LocalizedString.pricePerMonth(product.displayPrice),
                                   product: product,
                                   action: {
                    Task {
                        store.dispatch(.purchaseSubscription(product))
                    }
                    store.dispatch(.setSubscriptionSheetShowing(false, .manualOpen))
                })
            }

            // TODO: Localize
            SubscriptionOption(title: LocalizedString.free, detail: "4 free chapters", product: nil, action: { })

            Button {
                Task {
                    store.dispatch(.restoreSubscriptions)
                    store.dispatch(.setSubscriptionSheetShowing(false, .manualOpen))
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

enum SubscriptionLevel: CaseIterable {
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

    var idString: String {
        switch self {
        case .level1:
            "com.flowtale.level_1"
        case .level2:
            "com.flowtale.level_2"
        case .level3:
            "com.flowtale.level_3"
        case .max:
            "MAX_SUB_FOR_DEBUG"
        }
    }

    init?(id: String) {
        guard let level = SubscriptionLevel.allCases.first(where: { $0.idString == id }) else {
            return nil
        }
        self = level
    }
}
