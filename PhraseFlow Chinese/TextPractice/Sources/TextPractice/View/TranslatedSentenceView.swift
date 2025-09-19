//
//  TranslatedSentenceView.swift
//  FlowTale
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI
import FTFont
import FTColor
import TextGeneration
import Localization

struct TranslatedSentenceView: View {
    @EnvironmentObject var store: TextPracticeStore

    var body: some View {
        VStack(spacing: 8) {
            if let sentence = store.state.chapter.currentSentence {
                Text(sentence.original)
                    .font(FTFont.bodyMedium.font)
                    .foregroundColor(FTColor.primary.color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            } else {
                // No sentence selected state
                VStack {
                    Text(LocalizedString.selectSentenceToSeeTranslation)
                        .font(FTFont.secondaryHeader.font)
                        .foregroundColor(FTColor.secondary.color)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
