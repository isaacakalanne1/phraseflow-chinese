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
    @Binding var inputText: String
    @FocusState.Binding var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(LocalizedString.enterText)
                .font(FTFont.flowTaleSubHeader())
                .foregroundColor(FTColor.primary.color)

            ZStack(alignment: .topTrailing) {
                TextEditor(text: $inputText)
                    .frame(height: 120)
                    .padding(10)
                    .scrollContentBackground(.hidden)
                    .background(FTColor.background.color)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(FTColor.secondary.color, lineWidth: 1)
                    )
                    .foregroundColor(FTColor.primary.color)
                    .focused($isInputFocused)
                
                if isInputFocused {
                    Button(action: {
                        isInputFocused = false
                    }) {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .font(.system(size: 16))
                            .foregroundColor(FTColor.secondary.color)
                            .padding(8)
                            .background(FTColor.background.color)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    .padding(8)
                }
            }
        }
    }
}
