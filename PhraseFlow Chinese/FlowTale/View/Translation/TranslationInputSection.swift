//
//  TranslationInputSection.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import SwiftUI

struct TranslationInputSection: View {
    @EnvironmentObject var store: FlowTaleStore
    @Binding var inputText: String
    @FocusState.Binding var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(LocalizedString.enterText)
                .font(.footnote)
                .foregroundColor(FlowTaleColor.primary)

            TextEditor(text: $inputText)
                .frame(height: 120)
                .padding(10)
                .scrollContentBackground(.hidden)
                .background(FlowTaleColor.background)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(FlowTaleColor.secondary, lineWidth: 1)
                )
                .foregroundColor(FlowTaleColor.primary)
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