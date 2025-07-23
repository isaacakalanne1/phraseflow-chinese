//
//  CharacterView.swift
//  FlowTale
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI
import FTFont
import FTColor

struct CharacterView: View {
    @EnvironmentObject var store: StoryStore

    let word: WordTimeStampData
    let sentence: Sentence
    let isTranslation: Bool

    var isTappedWord: Bool {
        store.state.definitionState.currentDefinition?.timestampData == word
    }

    var spokenWord: WordTimeStampData? {
        isTranslation ? store.state.translationState.currentSpokenWord : store.state.storyState.currentChapter?.currentSpokenWord
    }

    var currentSentence: Sentence? {
        isTranslation ? store.state.translationState.currentSentence : store.state.storyState.currentChapter?.currentSentence
    }

    var hasDefinition: Bool {
        store.state.definitionState.definition(timestampData: word) != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text(word.word)
                    .font(FTFont.flowTaleBodyMedium())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(isTappedWord ? FTColor.primary : (word == spokenWord ? FTColor.wordHighlight : FTColor.primary))
                    .background {
                        if isTappedWord {
                            FTColor.wordHighlight
                        } else if sentence.id == currentSentence?.id {
                            FTColor.highlight
                        }
                    }

                if isTappedWord && !hasDefinition {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(4)
                        .background(FTColor.background.opacity(0.7))
                        .cornerRadius(8)
                }
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { isTapped in
                    switch isTranslation {
                    case true:
                        store.dispatch(.translationAction(.selectTranslationWord(word)))
                    case false:
                        store.dispatch(.storyAction(.selectWord(word, playAudio: true)))
                    }
                }
                .onEnded { _ in
                    switch isTranslation {
                    case true:
                        store.dispatch(.translationAction(.clearTranslationDefinition))
                    case false:
                        store.dispatch(.definitionAction(.clearCurrentDefinition))
                    }
                }
        )
    }
}
