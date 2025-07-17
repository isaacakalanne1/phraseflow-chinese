//
//  TranslationResultsSection.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import Localization
import SwiftUI

struct TranslationResultsSection: View {
    @EnvironmentObject var store: FlowTaleStore
    let chapter: Chapter
    
    var body: some View {
        VStack(spacing: 8) {
            Text(LocalizedString.definition)
                .font(.flowTaleSecondaryHeader())
                .foregroundColor(.ftPrimary)

            DefinitionView(definition: store.state.translationState.currentDefinition)
                .frame(height: 150)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ftBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(.ftSecondary, lineWidth: 1)
                        )
                )

            Text(LocalizedString.translation)
                .font(.flowTaleSecondaryHeader())
                .foregroundColor(.ftPrimary)

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
                    .fill(.ftBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(.ftSecondary, lineWidth: 1)
                    )
            )
        }
    }
}
