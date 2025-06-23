//
//  TranslationResultsSection.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import SwiftUI

struct TranslationResultsSection: View {
    @EnvironmentObject var store: FlowTaleStore
    let chapter: Chapter
    
    var body: some View {
        VStack(spacing: 8) {
            Text(LocalizedString.definition)
                .font(.headline)
                .foregroundColor(FlowTaleColor.primary)

            DefinitionView(definition: store.state.translationState.currentDefinition)
                .frame(height: 150)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(FlowTaleColor.background)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(FlowTaleColor.secondary, lineWidth: 1)
                        )
                )

            Text(LocalizedString.translation)
                .font(.headline)
                .foregroundColor(FlowTaleColor.primary)

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
                    .foregroundColor(FlowTaleColor.accent)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(FlowTaleColor.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(FlowTaleColor.secondary, lineWidth: 1)
                    )
            )
        }
    }
}
