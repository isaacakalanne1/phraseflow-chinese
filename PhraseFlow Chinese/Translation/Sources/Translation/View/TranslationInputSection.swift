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
    @EnvironmentObject var store: TranslationStore
    @Binding var inputText: String
    @FocusState.Binding var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(LocalizedString.enterText)
                .font(FTFont.flowTaleSubHeader())
                .foregroundColor(FTColor.primary)

            ZStack(alignment: .topTrailing) {
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
                
                if isInputFocused {
                    Button(action: {
                        isInputFocused = false
                    }) {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .font(.system(size: 16))
                            .foregroundColor(FTColor.secondary)
                            .padding(8)
                            .background(FTColor.background)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    .padding(8)
                }
            }

            Picker("Translation Mode", selection: Binding(
                get: { store.state.mode },
                set: { store.dispatch(.updateTranslationMode($0)) }
            )) {
                ForEach(TranslationMode.allCases, id: \.self) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}
