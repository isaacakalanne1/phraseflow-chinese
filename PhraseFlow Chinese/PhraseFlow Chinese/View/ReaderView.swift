//
//  ReaderView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI

struct ReaderView: View {
    @EnvironmentObject var store: FastChineseStore
    let chapter: Chapter

    var body: some View {
        let currentSpokenWord = store.state.timestampData?.last(where: { store.state.currentPlaybackTime >= $0.time }) ?? store.state.timestampData?.first
        let startCharacterIndex = currentSpokenWord?.textOffset ?? 0
        let (selectedSentenceIndex, selectedCharacterIndex) = getSentenceAndCharIndex(textOffset: startCharacterIndex) ?? (0,0)

        VStack(spacing: 10) {
            DefinitionView()
                .frame(height: 150)
            EnglishSentenceView()
                .frame(height: 100)
            ChapterView(chapter: chapter,
                        currentSpokenWord: currentSpokenWord,
                        selectedSentenceIndex: selectedSentenceIndex,
                        selectedCharacterIndex: selectedCharacterIndex)
            Spacer()
            ActionButtonsView(chapter: chapter)
                .padding(.horizontal)
        }
    }

    func getSentenceAndCharIndex(textOffset: Int) -> (sentenceIndex: Int, characterIndex: Int)? {
        var totalCharacterIndex = 0

        for (sentenceIndex, sentence) in chapter.sentences.enumerated() {
            let mandarinCharacters = Array(sentence.mandarin)
            let sentenceLength = mandarinCharacters.count

            if totalCharacterIndex + sentenceLength > textOffset {
                let characterIndex = textOffset - totalCharacterIndex
                if sentenceIndex != store.state.sentenceIndex {
                    store.dispatch(.updateSentenceIndex(sentenceIndex))
                }
                return (sentenceIndex, characterIndex)
            } else {
                totalCharacterIndex += sentenceLength
            }
        }
        return nil
    }
}
