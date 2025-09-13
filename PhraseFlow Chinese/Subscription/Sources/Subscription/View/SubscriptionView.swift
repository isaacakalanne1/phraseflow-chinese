//
//  SubscriptionView.swift
//  FlowTale
//
//  Created by iakalann on 13/12/2024.
//

import Localization
import DataStorage
import StoreKit
import SwiftUI
import FTFont
import FTColor

struct SubscriptionView: View {
    @EnvironmentObject var store: SubscriptionStore

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 20)
                
                if !(store.state.products?.isEmpty ?? false) {
                    subscriptionOptionsSection
                }
                
                freeTierSection
                
                actionsSection
                
                if store.state.isSubscribed {
                    managementInstructionsSection
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    FTColor.background,
                    FTColor.background.opacity(0.95),
                    FTColor.secondary
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationBarTitleDisplayMode(.inline)
        .overlay(content: {
            Group {
                if store.state.isLoadingSubscriptionPurchase {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .background(.ultraThinMaterial)
                        
                        VStack(spacing: 20) {
                            ProgressView()
                                .tint(FTColor.accent)
                                .scaleEffect(1.5)
                                .progressViewStyle(CircularProgressViewStyle())
                            
                            Text(LocalizedString.processing)
                                .font(FTFont.flowTaleSecondaryHeader())
                                .fontWeight(.medium)
                                .foregroundColor(FTColor.primary)
                        }
                        .padding(32)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(FTColor.background)
                                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                        )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        })

    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text(store.state.isSubscribed ? LocalizedString.manageSubscription : LocalizedString.subscribe)
                    .font(FTFont.flowTaleHeader())
                    .fontWeight(.heavy)
                    .foregroundColor(FTColor.primary)
                    .multilineTextAlignment(.center)
                
                if !store.state.isSubscribed {
                    Text(LocalizedString.subscriptionSubscribeNow)
                        .multilineTextAlignment(.center)
                        .font(FTFont.flowTaleSecondaryHeader())
                        .fontWeight(.medium)
                        .foregroundColor(FTColor.primary.opacity(0.7))
                        .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    @ViewBuilder
    private var subscriptionOptionsSection: some View {
        VStack(spacing: 20) {
            Text(LocalizedString.chooseYourPlan)
                .font(FTFont.flowTaleSecondaryHeader())
                .fontWeight(.semibold)
                .foregroundColor(FTColor.primary)
                .padding(.bottom, 8)
            
            VStack(spacing: 16) {
                ForEach(store.state.products?.sorted(by: { $0.price > $1.price }) ?? []) { product in
                    let limitString: String
                    if let characterLimit = SubscriptionLevel(id: product.id)?.ssmlCharacterLimitPerDay {
                        limitString = LocalizedString.subscriptionCharactersPerDay(characterLimit)
                    } else {
                        limitString = product.displayName
                    }
                    return SubscriptionOption(title: LocalizedString.pricePerMonth(product.displayPrice),
                                      detail: limitString,
                                      product: product,
                                      action: {
                                          Task {
                                              store.dispatch(.validateReceipt)
                                              store.dispatch(.purchaseSubscription(product))
                                          }
                                      })
                }
            }
        }
        .padding(.horizontal, 4)
    }
    
    private var freeTierSection: some View {
        SubscriptionOption(
            title: LocalizedString.free,
            detail: LocalizedString.subscriptionFreeCharactersDetail(4000),
            product: nil,
            action: {}
        )
        .disabled(true)
    }
    
    private var actionsSection: some View {
        VStack(spacing: 24) {
            Divider()
                .overlay(FTColor.secondary.opacity(0.3))
            
            Button {
                Task {
                    store.dispatch(.validateReceipt)
                    store.dispatch(.restoreSubscriptions)
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text(LocalizedString.restoreSubscription)
                }
                .multilineTextAlignment(.center)
                .font(FTFont.flowTaleSecondaryHeader())
                .fontWeight(.semibold)
                .foregroundColor(FTColor.primary)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(FTColor.primary.opacity(0.3), lineWidth: 1.5)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(FTColor.background)
                        )
                )
            }
            .buttonStyle(PressedButtonStyle())
            
            HStack(spacing: 32) {
                Button {
                    if let url = URL(string: "https://www.smileydude.co.uk/post/flowtale-terms-of-use-eula") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                } label: {
                    Text(LocalizedString.termsOfUse)
                        .multilineTextAlignment(.center)
                        .font(FTFont.flowTaleSecondaryHeader())
                        .foregroundColor(FTColor.primary.opacity(0.6))
                        .underline()
                }

                Button {
                    if let url = URL(string: "https://www.smileydude.co.uk/post/flowtale-privacy-policy") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                } label: {
                    Text(LocalizedString.privacyPolicy)
                        .multilineTextAlignment(.center)
                        .font(FTFont.flowTaleSecondaryHeader())
                        .foregroundColor(FTColor.primary.opacity(0.6))
                        .underline()
                }
            }
        }
    }
    
    private var managementInstructionsSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(FTColor.accent)
                .font(.title2)
            
            Text(LocalizedString.manageSubscriptionsInstructions)
                .multilineTextAlignment(.center)
                .font(FTFont.flowTaleSecondaryHeader())
                .foregroundColor(FTColor.primary.opacity(0.7))
                .padding(.horizontal, 8)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(FTColor.accent.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(FTColor.accent.opacity(0.3), lineWidth: 1)
                )
        )
    }
}
