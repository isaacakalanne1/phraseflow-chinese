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
import Study

struct TranslationResultsSection: View {
    @EnvironmentObject var store: TranslationStore
    let chapter: Chapter
    
    var body: some View {
        VStack(spacing: 8) {
            Text(LocalizedString.definition)
                .font(FTFont.flowTaleSecondaryHeader())
                .foregroundColor(FTColor.primary)

            DefinitionView(definition: store.state.currentDefinition)
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
                TranslationSentencesView(chapter: chapter)

                Button {
                    if store.state.isPlayingAudio {
                        store.dispatch(.pauseTranslationAudio)
                    } else {
                        store.dispatch(.playTranslationAudio)
                    }
                } label: {
                    Image(systemName: store.state.isPlayingAudio ?
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

struct TranslationSentencesView: View {
    @EnvironmentObject var store: TranslationStore
    let chapter: Chapter
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(chapter.sentences, id: \.id) { sentence in
                    Text(sentence.text)
                        .font(FTFont.flowTaleBodyMedium())
                        .foregroundColor(FTColor.primary)
                        .padding(.vertical, 4)
                        .background(
                            store.state.currentSentence?.id == sentence.id ? 
                            FTColor.accent.opacity(0.1) : Color.clear
                        )
                        .cornerRadius(4)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
