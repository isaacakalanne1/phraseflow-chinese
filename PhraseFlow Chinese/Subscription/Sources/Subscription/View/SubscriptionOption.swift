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
import Localization

struct SubscriptionOption: View {
    @EnvironmentObject var store: SubscriptionStore

    let title: String
    let detail: String
    let product: Product?
    let action: () -> Void

    var isUserCurrentSubscription: Bool {
        product != nil && store.state.currentSubscription.idString == product?.id
    }

    var backgroundColor: Color {
        if let _ = product {
            if isUserCurrentSubscription {
                return FTColor.accent
            } else {
                return FTColor.background
            }
        } else {
            return FTColor.secondary
        }
    }

    var foregroundColor: Color {
        if let _ = product {
            if isUserCurrentSubscription {
                return FTColor.background
            } else {
                return FTColor.primary
            }
        } else {
            return FTColor.primary
        }
    }
    
    var borderColor: Color {
        if let _ = product {
            if isUserCurrentSubscription {
                return FTColor.accent
            } else {
                return FTColor.primary.opacity(0.2)
            }
        } else {
            return FTColor.secondary
        }
    }
    
    var shadowColor: Color {
        if isUserCurrentSubscription {
            return FTColor.accent.opacity(0.3)
        } else {
            return Color.black.opacity(0.1)
        }
    }

    var body: some View {
        Button(action: {
            if product != nil {
                action()
            }
        }, label: {
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        if isUserCurrentSubscription {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(FTColor.background)
                                .font(.title3)
                                .fontWeight(.semibold)
                        } else {
                            Image(systemName: "crown.fill")
                                .foregroundColor(FTColor.accent)
                                .font(.title3)
                        }
                        
                        Text(title)
                            .font(FTFont.flowTaleHeader())
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        if isUserCurrentSubscription {
                            Text(LocalizedString.currentPlan)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(FTColor.background.opacity(0.8))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(FTColor.background.opacity(0.2))
                                )
                        }
                    }
                    
                    Text(detail)
                        .font(FTFont.flowTaleSecondaryHeader())
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                        .opacity(isUserCurrentSubscription ? 0.9 : 0.8)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        isUserCurrentSubscription ? 
                        LinearGradient(
                            colors: [backgroundColor, backgroundColor.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [backgroundColor, backgroundColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: shadowColor, radius: isUserCurrentSubscription ? 12 : 6, x: 0, y: isUserCurrentSubscription ? 6 : 3)
            )
            .foregroundColor(foregroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(borderColor, lineWidth: isUserCurrentSubscription ? 2 : 1)
            )
            .scaleEffect(isUserCurrentSubscription ? 1.02 : 1.0)
        })
        .buttonStyle(PressedButtonStyle())
    }
}

struct PressedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
