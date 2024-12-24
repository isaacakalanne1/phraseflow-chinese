//
//  SubscriptionView.swift
//  FlowTale
//
//  Created by iakalann on 13/12/2024.
//

import SwiftUI

struct SubscriptionView: View {
    @EnvironmentObject var store: FlowTaleStore

    var body: some View {
        VStack(spacing: 20) {
            let product = store.state.subscriptionState.products?.first
            Text(store.state.subscriptionState.isSubscribed ? "Manage" : "Subscribe")
                .font(.title)
                .bold()
                .foregroundColor(Color.primary)
            Text("Subscribe now for unlimited chapters")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .bold()
                .foregroundColor(Color.primary)

            SubscriptionOption(title: "\(product?.displayPrice ?? "...") per month",
                               detail: "\(product?.displayName ?? "...")",
                               product: product,
                               action: {
                Task {
                    if let prod = product {
                        store.dispatch(.purchaseSubscription(prod))
                    }
                }
                store.dispatch(.setSubscriptionSheetShowing(false))
            })

            SubscriptionOption(title: "Free", detail: "2 chapters per story", product: nil, action: { })

            Button {
                Task {
                    store.dispatch(.restoreSubscriptions)
                    store.dispatch(.setSubscriptionSheetShowing(false))
                }
            } label: {
                Text("Restore subscription")
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(Color.primary)
            }

            HStack {
                Button {
                    if let url = URL(string: "https://www.smileydude.co.uk/post/terms-of-use-eula") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                } label: {
                    Text("Terms of Use (EULA)")
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .foregroundColor(Color.primary)
                }

                Button {
                    if let url = URL(string: "https://www.smileydude.co.uk/post/privacy-policy") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                } label: {
                    Text("Privacy Policy")
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .foregroundColor(Color.primary)
                }
            }


            if store.state.subscriptionState.isSubscribed {
                Text("To manage your subscriptions, go to iOS Settings App -> Apple ID -> Subscriptions")
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .foregroundColor(Color.primary)
            }
        }
        .padding([.top, .leading, .trailing], 20)
        .frame(maxHeight: .infinity, alignment: .top)
        .edgesIgnoringSafeArea(.all)
    }
}

