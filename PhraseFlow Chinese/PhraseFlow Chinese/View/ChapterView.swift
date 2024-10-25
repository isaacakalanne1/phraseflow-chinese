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
        var spokenSentenceIndex = 0
        var spokenCharacterIndex = 0
        ScrollView(.vertical) {
            let currentSpokenWord = store.state.timestampData.last(where: { store.state.currentPlaybackTime >= $0.time })
            let startCharacterIndex = currentSpokenWord?.textOffset ?? 0
            var sentenceIndex = 0
            let (selectedSentenceIndex, selectedCharacterIndex) = getSentenceAndCharIndex(textOffset: startCharacterIndex) ?? (0,0)

            ForEach(Array(chapter.sentences.enumerated()), id: \.element) { (sentenceIndex, sentence) in
                let columns = Array(repeating: GridItem(.flexible(minimum: 30, maximum: 50), spacing: 0), count: 10)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 30, maximum: 50), spacing: 0),
                                         count: 10),
                          spacing: 0) {
                    ForEach(Array(sentence.mandarin.enumerated()), id: \.offset) { characterIndex, element in
                        let character = sentence.mandarin[characterIndex]
                        let pinyin = sentence.pinyin.count > characterIndex ? sentence.pinyin[characterIndex] : ""
                        CharacterView(currentSpokenWord: currentSpokenWord,
                                      sentences: chapter.sentences,
                                      isHighlighted: sentenceIndex == selectedSentenceIndex && (characterIndex >= selectedCharacterIndex && characterIndex < selectedCharacterIndex + (currentSpokenWord?.wordLength ?? 1)),
                                      character: character,
                                      pinyin: pinyin,
                                      characterIndex: characterIndex,
                                      sentenceIndex: sentenceIndex)
                    }
                }
            }
        }
    }

    func getSentenceAndCharIndex(textOffset: Int) -> (sentenceIndex: Int, characterIndex: Int)? {
        var totalCharacterIndex = 0

        for (sentenceIndex, sentence) in chapter.sentences.enumerated() {
            let mandarinCharacters = Array(sentence.mandarin)
            let sentenceLength = mandarinCharacters.count

            if totalCharacterIndex + sentenceLength > textOffset {
                let characterIndex = textOffset - totalCharacterIndex
                return (sentenceIndex, characterIndex)
            } else {
                totalCharacterIndex += sentenceLength
            }
        }
        return nil
    }
}
