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
    @EnvironmentObject var store: StoryStore

    var body: some View {
        VStack(spacing: 8) {
            if store.state.currentChapter?.currentSentence != nil {
                if (try? store.environment.isShowingEnglish()) == true {
                    // Show translation with scroll indicators
                    Text(store.state.currentChapter?.currentSentence?.original ?? "")
                        .font(FTFont.flowTaleBodyMedium())
                        .foregroundColor(FTColor.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                } else {
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
