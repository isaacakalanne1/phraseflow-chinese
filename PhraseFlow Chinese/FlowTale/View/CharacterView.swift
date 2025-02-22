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
        store.state.currentTappedWord == word
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
                    } else if store.state.storyState.currentStory?.currentSentenceIndex == word.sentenceIndex {
                        FlowTaleColor.highlight
                    }
                }
        }
        .onTapGesture {
            if !store.state.viewState.isDefining {
                store.dispatch(.updateAutoScrollEnabled(isEnabled: false))
                store.dispatch(.updateSentenceIndex(word.sentenceIndex))
                store.dispatch(.selectWord(word))
                if store.state.settingsState.isShowingDefinition {
                    store.dispatch(.defineCharacter(word, shouldForce: false))
                }
            }
        }
    }
}
