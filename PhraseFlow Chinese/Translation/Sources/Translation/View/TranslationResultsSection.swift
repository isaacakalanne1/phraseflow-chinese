//
//  TranslationResultsSection.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import Localization
import SwiftUI
import FTFont
import FTColor
import TextGeneration

struct TranslationResultsSection: View {
    @EnvironmentObject var store: TranslationStore
    let chapter: Chapter
    
    var body: some View {
        VStack(spacing: 8) {
            Text(LocalizedString.definition)
                .font(FTFont.flowTaleSecondaryHeader())
                .foregroundColor(FTColor.primary)

            DefinitionView(definition: store.state.translationState.currentDefinition)
                .frame(height: 150)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(FTColor.background)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(FTColor.secondary, lineWidth: 1)
                        )
                )

            Text(LocalizedString.translation)
                .font(FTFont.flowTaleSecondaryHeader())
                .foregroundColor(FTColor.primary)

            HStack(alignment: .top) {
                ListOfSentencesView(isTranslation: true)

                Button {
                    if store.state.translationState.isPlayingAudio {
                        store.dispatch(.translationAction(.pauseTranslationAudio))
                    } else {
                        store.dispatch(.translationAction(.playTranslationAudio))
                    }
                } label: {
                    Image(systemName: store.state.translationState.isPlayingAudio ?
                          "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(FTColor.accent)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(FTColor.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(FTColor.secondary, lineWidth: 1)
                    )
            )
        }
    }
}
