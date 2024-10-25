//
//  ChapterView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI

struct ChapterView: View {
    @EnvironmentObject var store: FastChineseStore
    let chapter: Chapter

    var body: some View {
        ScrollView(.vertical) {
            let currentSpokenWord = store.state.timestampData.last(where: { store.state.currentPlaybackTime >= $0.time })
            ForEach(Array(chapter.sentences.enumerated()), id: \.element) { (sentenceIndex, sentence) in
                let columns = Array(repeating: GridItem(.flexible(minimum: 30, maximum: 50), spacing: 0), count: 10)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 30, maximum: 50), spacing: 0),
                                         count: 10),
                          spacing: 0) {
                    ForEach(Array(sentence.mandarin.enumerated()), id: \.offset) { characterIndex, element in
                        let character = sentence.mandarin[characterIndex]
                        let pinyin = sentence.pinyin.count > characterIndex ? sentence.pinyin[characterIndex] : ""
                        CharacterView(currentSpokenWord: currentSpokenWord,
                                      characterIndex: characterIndex,
                                      sentenceIndex: sentenceIndex,
                                      character: character,
                                      pinyin: pinyin)
                    }
                }
            }
        }
    }
}
