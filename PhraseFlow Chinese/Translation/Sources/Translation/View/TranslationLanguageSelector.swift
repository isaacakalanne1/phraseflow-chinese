//
//  TranslationLanguageSelector.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import SwiftUI
import FTFont
import FTColor
import Localization

struct TranslationLanguageSelector: View {
    @EnvironmentObject var store: TranslationStore
    @Binding var showLanguageSelector: Bool
    @Binding var showSourceLanguageSelector: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(LocalizedString.translateBetweenLanguages)
                .font(FTFont.subHeader.font)
                .foregroundColor(FTColor.secondary.color)

            HStack(spacing: 8) {
                sourceLanguageButton
                swapLanguagesButton
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
                    .font(FTFont.bodyXSmall.font)
                Text(store.state.settings.sourceLanguage.displayName)
                    .font(FTFont.subHeader.font)
                    .fontWeight(.medium)
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(FTFont.secondaryHeader.font)
            }
            .foregroundColor(FTColor.primary.color)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(
                Capsule()
                    .fill(FTColor.background.color)
                    .overlay(
                        Capsule()
                            .strokeBorder(FTColor.secondary.color, lineWidth: 1)
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
                .font(FTFont.bodyXSmall.font)
                .foregroundColor(store.state.settings.sourceLanguage == .autoDetect ?
                                FTColor.secondary.color : FTColor.accent.color)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .strokeBorder(store.state.settings.sourceLanguage == .autoDetect ?
                                     FTColor.secondary.color : FTColor.accent.color, lineWidth: 1)
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
                    .font(FTFont.bodyXSmall.font)
                Text(store.state.settings.targetLanguage.displayName)
                    .font(FTFont.subHeader.font)
                    .fontWeight(.medium)
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(FTFont.secondaryHeader.font)
            }
            .foregroundColor(FTColor.primary.color)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(
                Capsule()
                    .fill(FTColor.background.color)
                    .overlay(
                        Capsule()
                            .strokeBorder(FTColor.secondary.color, lineWidth: 1)
                    )
            )
        }
    }
}
