//
//  CharacterView.swift
//  FlowTale
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI

struct CharacterView: View {
    @EnvironmentObject var store: FlowTaleStore

    let isHighlighted: Bool
    
    let word: WordTimeStampData

    var isTappedWord: Bool {
        store.state.definitionState.currentWord?.id == word.id
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(word.word)
                .font(.system(size: 25, weight: .light))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(isTappedWord ? FlowTaleColor.primary : (isHighlighted ? FlowTaleColor.wordHighlight : FlowTaleColor.primary))
                .background {
                    if isTappedWord {
                        FlowTaleColor.wordHighlight
                    } else {
                        // Find if this word is in the current sentence
                        let currentSentenceIndex = store.state.storyState.currentStory?.currentSentenceIndex ?? 0
                        if let chapter = store.state.storyState.currentChapter,
                           currentSentenceIndex < chapter.sentences.count,
                           chapter.sentences[currentSentenceIndex].wordTimestamps.contains(where: { $0.id == word.id }) {
                            FlowTaleColor.highlight
                        }
                    }
                }
        }
        .onTapGesture {
            if !store.state.viewState.isDefining {
                store.dispatch(.updateAutoScrollEnabled(isEnabled: false))
                
                // Find which sentence contains this word
                if let chapter = store.state.storyState.currentChapter {
                    for (sentenceIndex, sentence) in chapter.sentences.enumerated() {
                        if sentence.wordTimestamps.contains(where: { $0.id == word.id }) {
                            store.dispatch(.updateSentenceIndex(sentenceIndex))
                            break
                        }
                    }
                }
                
                store.dispatch(.selectWord(word))
                if store.state.settingsState.isShowingDefinition {
                    store.dispatch(.defineCharacter(word, shouldForce: false))
                }
            }
        }
    }
}
