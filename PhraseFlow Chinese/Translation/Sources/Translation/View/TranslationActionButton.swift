//
//  TranslationActionButton.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import Localization
import SwiftUI
import FTFont
import FTColor

struct TranslationActionButton: View {
    @EnvironmentObject var store: TranslationStore
    @FocusState.Binding var isInputFocused: Bool
    
    var body: some View {
        Button {
            store.dispatch(.translateText)
            isInputFocused = false // Dismiss the keyboard when button is tapped
        } label: {
            HStack {
                if store.state.isTranslating {
                    ProgressView()
                        .tint(.white)
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 8)
                } else {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(FTFont.flowTaleBodySmall())
                        .padding(.trailing, 8)
                }
                
                let buttonText = store.state.isTranslating ? LocalizedString.translating : LocalizedString.translate
                
                Text(buttonText)
                    .font(FTFont.flowTaleSecondaryHeader())
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(store.state.inputText.isEmpty ||
                          store.state.isTranslating ?
                          Color.gray.opacity(0.5) : FTColor.accent)
            )
        }
        .disabled(store.state.inputText.isEmpty || store.state.isTranslating)
    }
}
