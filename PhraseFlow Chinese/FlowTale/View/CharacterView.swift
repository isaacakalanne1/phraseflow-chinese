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

    var body: some View {
        VStack(spacing: 0) {
            Text(word.word)
                .font(.system(size: 25, weight: .light))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(isHighlighted ? Color.blue : Color.black)
                .background {
                    if store.state.storyState.sentenceIndex == word.sentenceIndex {
                        Color.gray.opacity(0.3)
                    }
                }
        }
        .onTapGesture {
            if store.state.viewState.readerDisplayType != .defining {
                store.dispatch(.updateSentenceIndex(word.sentenceIndex))
                store.dispatch(.selectWord(word))
                if store.state.settingsState.isShowingDefinition {
                    store.dispatch(.defineCharacter(word, shouldForce: false))
                }
            }
        }
    }
}
