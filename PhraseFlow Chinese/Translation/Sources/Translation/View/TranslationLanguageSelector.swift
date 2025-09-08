//
//  TranslationLanguageSelector.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import SwiftUI
import FTFont
import FTColor

struct TranslationLanguageSelector: View {
    @EnvironmentObject var store: TranslationStore
    @Binding var showLanguageSelector: Bool
    @Binding var showSourceLanguageSelector: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            if store.state.mode == .translate {
                Text("Translate between languages") // TODO: Localize
                    .font(FTFont.flowTaleSubHeader())
                    .foregroundColor(FTColor.secondary)

                HStack(spacing: 8) {
                    // Source language selector
                    sourceLanguageButton
                    
                    // Swap languages button (or one-way arrow for auto-detect)
                    swapLanguagesButton
                    
                    // Target language selector
                    targetLanguageButton
                }
            } else {
                // Breakdown mode - only show text language selector
                Text("Select text language") // TODO: Localize
                    .font(FTFont.flowTaleSubHeader())
                    .foregroundColor(FTColor.secondary)

                targetLanguageButton
            }
        }
    }
    
    private var sourceLanguageButton: some View {
        Button {
            showSourceLanguageSelector = true
        } label: {
            HStack(spacing: 6) {
                Text(store.state.settings.sourceLanguage.flagEmoji)
                    .font(FTFont.flowTaleBodyXSmall())
                Text(store.state.settings.sourceLanguage.displayName)
                    .font(FTFont.flowTaleSubHeader())
                    .fontWeight(.medium)
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(FTFont.flowTaleSecondaryHeader())
            }
            .foregroundColor(FTColor.primary)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(
                Capsule()
                    .fill(FTColor.background)
                    .overlay(
                        Capsule()
                            .strokeBorder(FTColor.secondary, lineWidth: 1)
                    )
            )
        }
    }
    
    private var swapLanguagesButton: some View {
        Button {
            store.dispatch(.swapLanguages)
        } label: {
            Image(systemName: store.state.settings.sourceLanguage == .autoDetect ?
                  "arrow.right" : "arrow.left.arrow.right")
                .font(FTFont.flowTaleBodyXSmall())
                .foregroundColor(store.state.settings.sourceLanguage == .autoDetect ?
                                FTColor.secondary : FTColor.accent)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .strokeBorder(store.state.settings.sourceLanguage == .autoDetect ?
                                     FTColor.secondary : FTColor.accent, lineWidth: 1)
                )
        }
        .disabled(store.state.settings.sourceLanguage == .autoDetect)
    }
    
    private var targetLanguageButton: some View {
        Button {
            showLanguageSelector = true
        } label: {
            HStack(spacing: 6) {
                Text(store.state.settings.targetLanguage.flagEmoji)
                    .font(FTFont.flowTaleBodyXSmall())
                Text(store.state.settings.targetLanguage.displayName)
                    .font(FTFont.flowTaleSubHeader())
                    .fontWeight(.medium)
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(FTFont.flowTaleSecondaryHeader())
            }
            .foregroundColor(FTColor.primary)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(
                Capsule()
                    .fill(FTColor.background)
                    .overlay(
                        Capsule()
                            .strokeBorder(FTColor.secondary, lineWidth: 1)
                    )
            )
        }
    }
}
