//
//  TranslationInputSection.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import Localization
import SwiftUI
import FTFont
import FTColor

struct TranslationInputSection: View {
    @EnvironmentObject var store: FlowTaleStore
    @Binding var inputText: String
    @FocusState.Binding var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(LocalizedString.enterText)
                .font(.flowTaleSubHeader())
                .foregroundColor(FTColor.primary)

            TextEditor(text: $inputText)
                .frame(height: 120)
                .padding(10)
                .scrollContentBackground(.hidden)
                .background(FTColor.background)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(FTColor.secondary, lineWidth: 1)
                )
                .foregroundColor(FTColor.primary)
                .focused($isInputFocused)

            Picker("Translation Mode", selection: Binding(
                get: { store.state.translationState.mode },
                set: { store.dispatch(.translationAction(.updateTranslationMode($0))) }
            )) {
                ForEach(TranslationMode.allCases, id: \.self) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}
