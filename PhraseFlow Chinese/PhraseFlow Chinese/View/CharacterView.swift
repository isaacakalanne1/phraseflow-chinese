//
//  CharacterView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI

struct CharacterView: View {
    @EnvironmentObject var store: FastChineseStore
    let characterIndex: Int
    let sentenceIndex: Int
    let character: String
    let pinyin: String

    var body: some View {

        let currentSpokenWord = store.state.timestampData.last(where: { store.state.currentPlaybackTime >= $0.time })
        let wordStart = currentSpokenWord?.textOffset ?? -1
        let wordEnd = (currentSpokenWord?.textOffset ?? -1) + (currentSpokenWord?.wordLength ?? -1)
        let isHighlightedWord = (characterIndex >= wordStart) && (characterIndex < wordEnd)

        VStack {
            Text(character == pinyin ? "" : pinyin)
                .font(.footnote)
//                                            .foregroundStyle(isSelectedWord && isSelectedSentence ? Color.green : Color.primary)
                .opacity(store.state.isShowingPinyin ? 1 : 0)
            Text(character)
                .font(.title)
//                                            .foregroundStyle(isSelectedWord && isSelectedSentence ? Color.green : Color.primary)
                .opacity(store.state.isShowingMandarin ? 1 : 0)
        }
        .onTapGesture {
            store.dispatch(.updateSentenceIndex(sentenceIndex))
            for entry in store.state.timestampData {
                let wordStart = entry.textOffset
                let wordEnd = entry.textOffset + entry.wordLength
                if characterIndex >= wordStart && characterIndex < wordEnd {
                    store.dispatch(.updateSelectedWordIndices(startIndex: wordStart, endIndex: wordEnd))
                    store.dispatch(.defineCharacter(entry.word))
                    let resultEntry = (word: entry.word, time: entry.time)
                    print("Result entry is \(resultEntry)")
                    store.dispatch(.playAudio(time: entry.time))
                }
            }
        }
        .background(isHighlightedWord ? Color.gray : Color.white)
    }
}
