//
//  CharacterView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI

struct CharacterView: View {
    @EnvironmentObject var store: FastChineseStore
    let currentSpokenWord: WordTimeStampData?
    let sentences: [Sentence]
    let isHighlighted: Bool
    let character: String
    let pinyin: String
    let characterIndex: Int
    let sentenceIndex: Int

    var body: some View {
        let wordStart = currentSpokenWord?.textOffset ?? -1
        let wordEnd = (currentSpokenWord?.textOffset ?? -1) + (currentSpokenWord?.wordLength ?? -1)

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
            if let word = getSpokenWord(sentenceIndex: sentenceIndex, characterIndex: characterIndex) {
                store.dispatch(.selectWord(word))
            }
//            store.dispatch(.updateSentenceIndex(sentenceIndex))
//            for entry in store.state.timestampData {
//                let wordStart = entry.textOffset
//                let wordEnd = entry.textOffset + entry.wordLength
//                if characterIndex >= wordStart && characterIndex < wordEnd {
//                    store.dispatch(.updateSelectedWordIndices(startIndex: wordStart, endIndex: wordEnd))
//                    store.dispatch(.defineCharacter(entry.word))
//                    let resultEntry = (word: entry.word, time: entry.time)
//                    print("Result entry is \(resultEntry)")
//                    store.dispatch(.playAudio(time: entry.time))
//                }
//            }
        }
        .background(isHighlighted ? Color.gray : Color.white)
    }

    func getSpokenWord(sentenceIndex: Int, characterIndex: Int) -> WordTimeStampData? {
        // Calculate the overall character index
        var totalCharacterIndex = 0

        for (index, sentence) in sentences.enumerated() {
            let sentenceLength = sentence.mandarin.count

            if index < sentenceIndex {
                // Sum up the lengths of previous sentences
                totalCharacterIndex += sentenceLength
            } else if index == sentenceIndex {
                // Add the characterIndex within the current sentence
                totalCharacterIndex += characterIndex
                break
            } else {
                break
            }
        }

        // Now totalCharacterIndex is the overall index of the character
        // Find the SpokenWord in timestampData that includes this index
        for spokenWord in store.state.timestampData {
            let wordStart = spokenWord.textOffset
            let wordLength = spokenWord.wordLength
            let wordEnd = wordStart + wordLength - 1

            if totalCharacterIndex >= wordStart && totalCharacterIndex <= wordEnd {
                return spokenWord
            }
        }

        // If not found, return nil
        return nil
    }
}
