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

    var body: some View {
        VStack {
            Text(character == pinyin ? "" : pinyin)
                .font(.footnote)
                .opacity(store.state.isShowingPinyin ? 1 : 0)
            Text(character)
                .font(.title)
                .opacity(store.state.isShowingMandarin ? 1 : 0)
        }
        .onTapGesture {
            store.dispatch(.updateSentenceIndex(sentenceIndex))
            if let word = store.state.getSpokenWord(sentenceIndex: sentenceIndex, characterIndex: characterIndex) {
                store.dispatch(.selectWord(word))
                store.dispatch(.defineCharacter(word.word))
            }
        }
        .background(isHighlighted ? Color.gray : Color.white)
    }
}
