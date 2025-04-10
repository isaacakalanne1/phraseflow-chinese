//
//  TranslationLanguageSelector.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import SwiftUI

struct TranslationLanguageSelector: View {
    @EnvironmentObject var store: FlowTaleStore
    @Binding var showLanguageSelector: Bool
    @Binding var showSourceLanguageSelector: Bool
    @Binding var showTextLanguageSelector: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            if store.state.translationState.mode == .translate {
                Text("Translate between languages")
                    .font(.footnote)
                    .foregroundColor(FlowTaleColor.secondary)

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
                    .font(.footnote)
                    .foregroundColor(FlowTaleColor.secondary)

                textLanguageButton
            }
        }
    }
    
    private var sourceLanguageButton: some View {
        Button {
            showSourceLanguageSelector = true
        } label: {
            let sourceLanguage = store.state.translationState.sourceLanguage

            HStack(spacing: 6) {
                if sourceLanguage != nil {
                    Text(sourceLanguage!.flagEmoji)
                        .font(.system(size: 16))
                    Text(sourceLanguage!.displayName)
                        .font(.footnote)
                        .fontWeight(.medium)
                        .lineLimit(1)
                } else {
                    Text("🔍")
                        .font(.system(size: 16))
                    Text("Auto-detect")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .lineLimit(1)
                }
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
            .foregroundColor(FlowTaleColor.primary)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(
                Capsule()
                    .fill(FlowTaleColor.background)
                    .overlay(
                        Capsule()
                            .strokeBorder(FlowTaleColor.secondary, lineWidth: 1)
                    )
            )
        }
    }
    
    private var swapLanguagesButton: some View {
        Button {
            store.dispatch(.translationAction(.swapLanguages))
        } label: {
            Image(systemName: store.state.translationState.sourceLanguage == nil ?
                  "arrow.right" : "arrow.left.arrow.right")
                .font(.system(size: 16))
                .foregroundColor(store.state.translationState.sourceLanguage == nil ?
                                FlowTaleColor.secondary : FlowTaleColor.accent)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .strokeBorder(store.state.translationState.sourceLanguage == nil ?
                                     FlowTaleColor.secondary : FlowTaleColor.accent, lineWidth: 1)
                )
        }
        .disabled(store.state.translationState.sourceLanguage == nil)
    }
    
    private var targetLanguageButton: some View {
        Button {
            showLanguageSelector = true
        } label: {
            let targetLanguage = store.state.translationState.targetLanguage
            HStack(spacing: 6) {
                Text(targetLanguage.flagEmoji)
                    .font(.system(size: 16))
                Text(targetLanguage.displayName)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
            .foregroundColor(FlowTaleColor.primary)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(
                Capsule()
                    .fill(FlowTaleColor.background)
                    .overlay(
                        Capsule()
                            .strokeBorder(FlowTaleColor.secondary, lineWidth: 1)
                    )
            )
        }
    }
    
    private var textLanguageButton: some View {
        Button {
            showTextLanguageSelector = true
        } label: {
            let textLanguage = store.state.translationState.textLanguage
            HStack(spacing: 6) {
                Text(textLanguage.flagEmoji)
                    .font(.system(size: 16))
                Text(textLanguage.displayName)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
            .foregroundColor(FlowTaleColor.primary)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(
                Capsule()
                    .fill(FlowTaleColor.background)
                    .overlay(
                        Capsule()
                            .strokeBorder(FlowTaleColor.secondary, lineWidth: 1)
                    )
            )
        }
    }
}