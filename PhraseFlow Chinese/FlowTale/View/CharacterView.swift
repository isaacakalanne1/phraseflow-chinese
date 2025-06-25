//
//  CharacterView.swift
//  FlowTale
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI

struct CharacterView: View {
    @EnvironmentObject var store: FlowTaleStore

    let word: WordTimeStampData
    let sentence: Sentence
    let isTranslation: Bool

    var isTappedWord: Bool {
        store.state.definitionState.currentDefinition?.timestampData == word
    }

    var spokenWord: WordTimeStampData? {
        isTranslation ? store.state.translationState.currentSpokenWord : store.state.storyState.currentSpokenWord
    }

    var currentSentence: Sentence? {
        isTranslation ? store.state.translationState.currentSentence : store.state.storyState.currentSentence
    }

    var hasDefinition: Bool {
        store.state.definitionState.definition(timestampData: word) != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text(word.word)
                    .font(.system(size: 25, weight: .light))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(isTappedWord ? FlowTaleColor.primary : (word == spokenWord ? FlowTaleColor.wordHighlight : FlowTaleColor.primary))
                    .background {
                        if isTappedWord {
                            FlowTaleColor.wordHighlight
                        } else if sentence.id == currentSentence?.id {
                            FlowTaleColor.highlight
                        }
                    }

                if isTappedWord && !hasDefinition {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(4)
                        .background(FlowTaleColor.background.opacity(0.7))
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
