//
//  TranslationActionButton.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import SwiftUI

struct TranslationActionButton: View {
    @EnvironmentObject var store: FlowTaleStore
    @FocusState.Binding var isInputFocused: Bool
    
    var body: some View {
        Button {
            if store.state.translationState.mode == .translate {
                store.dispatch(.translationAction(.translateText))
            } else {
                store.dispatch(.translationAction(.breakdownText))
            }
            isInputFocused = false // Dismiss the keyboard when button is tapped
        } label: {
            HStack {
                if store.state.translationState.isTranslating {
                    ProgressView()
                        .tint(.white)
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 8)
                } else {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.flowTaleBodySmall())
                        .padding(.trailing, 8)
                }
                
                let buttonText = store.state.translationState.isTranslating ? 
                    LocalizedString.translating : 
                    (store.state.translationState.mode == .translate ? LocalizedString.translate : LocalizedString.breakdown)
                
                Text(buttonText)
                    .font(.flowTaleSecondaryHeader())
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(store.state.translationState.inputText.isEmpty ||
                          store.state.translationState.isTranslating ?
                          Color.gray.opacity(0.5) : FlowTaleColor.accent)
            )
        }
        .disabled(store.state.translationState.inputText.isEmpty ||
                  store.state.translationState.isTranslating)
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 16)
    }
}
