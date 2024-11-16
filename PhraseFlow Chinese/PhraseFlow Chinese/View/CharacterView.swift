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
    let character: String
    let pinyin: String
    let characterIndex: Int
    let sentenceIndex: Int
    let isLastCharacter: Bool
    private let cornerRadius: CGFloat = 7.5

    var body: some View {
        VStack(spacing: 0) {
            Text(character == pinyin ? " " : pinyin)
                .font(.system(size: 10))
                .opacity(store.state.settingsState.isShowingPinyin ? 1 : 0)
                .frame(maxWidth: .infinity)
            Text(character)
                .font(.system(size: 25, weight: .light))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(isHighlighted ? Color.blue : Color.black)
                .background {
                    Group  {
                        if sentenceIndex == store.state.storyState.sentenceIndex {
                            Color.gray.opacity(0.3)
                                .clipShape(
                                    .rect(
                                        topLeadingRadius: characterIndex == 0 ? cornerRadius : 0,
                                        bottomLeadingRadius: characterIndex == 0 ? cornerRadius : 0,
                                        bottomTrailingRadius: isLastCharacter ? cornerRadius : 0,
                                        topTrailingRadius: isLastCharacter ? cornerRadius : 0
                                    )
                                )
                        }
                    }
                }
        }
        .onTapGesture {
            if let word = store.state.getSpokenWord(sentenceIndex: sentenceIndex, characterIndex: characterIndex),
               store.state.viewState != .defining {
                store.dispatch(.updateSentenceIndex(sentenceIndex))
                store.dispatch(.selectWord(word))
                if store.state.settingsState.isShowingDefinition {
                    store.dispatch(.defineCharacter(word, shouldForce: false))
                }
            }
        }

    }
}
