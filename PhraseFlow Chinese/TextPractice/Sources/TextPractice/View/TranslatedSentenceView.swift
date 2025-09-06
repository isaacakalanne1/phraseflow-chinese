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
                switch store.state.viewState {
                case .showDefinition:
                    // Show translation with scroll indicators
                    Text(sentence.original)
                        .font(FTFont.flowTaleBodyMedium())
                        .foregroundColor(FTColor.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                case .normal:
                    // Show hidden state
                    VStack {
                        Image(systemName: "eye.slash")
                            .font(FTFont.flowTaleBodyMedium())
                            .foregroundColor(FTColor.secondary)
                            .padding(.bottom, 4)
                        
                        Text(LocalizedString.tapRevealToShow)
                            .font(FTFont.flowTaleSecondaryHeader())
                            .foregroundColor(FTColor.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            } else {
                // No sentence selected state
                VStack {
                    Text(LocalizedString.selectSentenceToSeeTranslation)
                        .font(FTFont.flowTaleSecondaryHeader())
                        .foregroundColor(FTColor.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
