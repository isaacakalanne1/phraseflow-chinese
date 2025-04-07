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
    let isCurrentSentence: Bool

    let word: WordTimeStampData

    var isTappedWord: Bool {
        store.state.definitionState.currentDefinition?.timestampData == word
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
                    } else if isCurrentSentence {
                        FlowTaleColor.highlight
                    }
                }
        }
        .onTapGesture {
            if !store.state.viewState.isDefining {
                store.dispatch(.updateAutoScrollEnabled(isEnabled: false))
                store.dispatch(.selectWord(word))
                if store.state.settingsState.isShowingDefinition {
                    store.dispatch(.defineSentence(word, shouldForce: false))
                }
            }
        }
    }
}
