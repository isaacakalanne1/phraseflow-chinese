//
//  CharacterView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI

struct CharacterView: View {
    @EnvironmentObject var store: FastChineseStore

    let isHighlighted: Bool
    let word: WordTimeStampData
    private let cornerRadius: CGFloat = 7.5

    var body: some View {
        VStack(spacing: 0) {
            Text(word.word)
                .font(.system(size: 25, weight: .light))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(isHighlighted ? Color.blue : Color.black)
                .background {
                    Group  {
                        if store.state.storyState.sentenceIndex == word.sentenceIndex {
                            Color.gray.opacity(0.3)
                                .clipShape(
                                    .rect(
                                        topLeadingRadius: word.wordPosition == .first ? cornerRadius : 0,
                                        bottomLeadingRadius: word.wordPosition == .first ? cornerRadius : 0,
                                        bottomTrailingRadius: word.wordPosition == .last ? cornerRadius : 0,
                                        topTrailingRadius: word.wordPosition == .last ? cornerRadius : 0
                                    )
                                )
                        }
                    }
                }
        }
        .onTapGesture {
            if let chapter = store.state.storyState.currentChapter,
               store.state.viewState.readerDisplayType != .defining {
                store.dispatch(.updateSentenceIndex(store.state.storyState.sentenceIndex))
                store.dispatch(.selectWord(word))
                if store.state.settingsState.isShowingDefinition {
                    store.dispatch(.defineCharacter(word, shouldForce: false))
                }
            }
        }

    }
}
