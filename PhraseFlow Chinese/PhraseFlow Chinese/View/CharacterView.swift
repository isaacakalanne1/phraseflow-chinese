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
        VStack(spacing: 0) {
            Text(character == pinyin ? "" : pinyin)
                .font(.system(size: 12))
                .opacity(store.state.isShowingPinyin ? 1 : 0)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Text(character)
                .font(.system(size: 25))
                .opacity(store.state.isShowingMandarin ? 1 : 0)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(isHighlighted ? Color.blue : sentenceIndex == store.state.sentenceIndex ? Color.gray : Color.white)
        }
        .onTapGesture {
            store.dispatch(.updateSentenceIndex(sentenceIndex))
            if let word = store.state.getSpokenWord(sentenceIndex: sentenceIndex, characterIndex: characterIndex) {
                store.dispatch(.selectWord(word))
                store.dispatch(.defineCharacter(word.word))
            }
        }
    }
}
