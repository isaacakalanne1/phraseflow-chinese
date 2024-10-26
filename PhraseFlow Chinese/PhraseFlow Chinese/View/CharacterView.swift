//
//  CharacterView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI

struct CharacterView: View {
    @EnvironmentObject var store: FastChineseStore
    
    let sentences: [Sentence]
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
            if let word = getSpokenWord(sentenceIndex: sentenceIndex, characterIndex: characterIndex) {
                store.dispatch(.selectWord(word))
                store.dispatch(.defineCharacter(word.word))
            }
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
        return store.state.timestampData.last(where: { totalCharacterIndex >= $0.textOffset})
    }
}
