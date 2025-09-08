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
    @Binding var showTextLanguageSelector: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            if store.state.mode == .translate {
                Text("Translate between languages")
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
                Text("Select text language")
                    .font(FTFont.flowTaleSubHeader())
                    .foregroundColor(FTColor.secondary)

                textLanguageButton
            }
        }
    }
    
    private var sourceLanguageButton: some View {
        Button {
            showSourceLanguageSelector = true
        } label: {
            let sourceLanguage = store.state.sourceLanguage

            HStack(spacing: 6) {
                if let sourceLanguage {
                    Text(sourceLanguage.flagEmoji)
                        .font(FTFont.flowTaleBodyXSmall())
                    Text(sourceLanguage.displayName)
                        .font(FTFont.flowTaleSubHeader())
                        .fontWeight(.medium)
                        .lineLimit(1)
                } else {
                    Text("🔍")
                        .font(FTFont.flowTaleBodyXSmall())
                    Text("Auto-detect")
                        .font(FTFont.flowTaleSubHeader())
                        .fontWeight(.medium)
                        .lineLimit(1)
                }
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
            Image(systemName: store.state.sourceLanguage == nil ?
                  "arrow.right" : "arrow.left.arrow.right")
                .font(FTFont.flowTaleBodyXSmall())
                .foregroundColor(store.state.sourceLanguage == nil ?
                                FTColor.secondary : FTColor.accent)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .strokeBorder(store.state.sourceLanguage == nil ?
                                     FTColor.secondary : FTColor.accent, lineWidth: 1)
                )
        }
        .disabled(store.state.sourceLanguage == nil)
    }
    
    private var targetLanguageButton: some View {
        Button {
            showLanguageSelector = true
        } label: {
            let targetLanguage = store.state.targetLanguage
            HStack(spacing: 6) {
                Text(targetLanguage.flagEmoji)
                    .font(FTFont.flowTaleBodyXSmall())
                Text(targetLanguage.displayName)
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
    
    private var textLanguageButton: some View {
        Button {
            showTextLanguageSelector = true
        } label: {
            let textLanguage = store.state.targetLanguage
            HStack(spacing: 6) {
                Text(textLanguage.flagEmoji)
                    .font(FTFont.flowTaleBodyXSmall())
                Text(textLanguage.displayName)
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
