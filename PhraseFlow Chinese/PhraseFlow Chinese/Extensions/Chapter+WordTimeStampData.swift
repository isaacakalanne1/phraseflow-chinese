//
//  Chapter+WordTimeStampData.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 16/11/2024.
//

import Foundation

extension Chapter {
    func getWordTimeStampData(atSentenceIndex sentenceIndex: Int, characterIndex: Int) -> WordTimeStampData? {
        // Calculate the overall character index
        var totalCharacterIndex = 0

        for (index, sentence) in self.sentences.enumerated() {
            let sentenceLength = sentence.translation.count

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
        // Find the SpokenWord in chapterTimestampData that includes this index
        return self.timestampData.last(where: { totalCharacterIndex >= $0.textOffset})
    }
}
