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
    let currentSpokenWord: WordTimeStampData?
    let selectedSentenceIndex: Int
    let selectedCharacterIndex: Int

    var body: some View {
        let cumulativeCharacterCounts: [Int] = {
            var counts: [Int] = []
            var cumulativeCount = 0
            for sentence in chapter.sentences {
                counts.append(cumulativeCount)
                cumulativeCount += sentence.mandarinTranslation.count
            }
            return counts
        }()

        // Compute the global index of the selected character
        let wordLength = currentSpokenWord?.wordLength ?? 1
        let globalSelectedCharacterIndex = cumulativeCharacterCounts[selectedSentenceIndex] + selectedCharacterIndex

        ScrollView(.vertical) {
            ForEach(Array(chapter.sentences.enumerated()), id: \.element) { (sentenceIndex, sentence) in
                let cumulativeSentenceStartIndex = cumulativeCharacterCounts[sentenceIndex]
                
                FlowLayout(spacing: 0) {
                    ForEach(Array(sentence.mandarinTranslation.enumerated()), id: \.offset) { characterIndex, character in
//                        let pinyin = sentence.pinyin[safe: characterIndex] ?? " "
                        let pinyin = " "
                        // Compute the global character index
                        let globalCharacterIndex = cumulativeSentenceStartIndex + characterIndex

                        // Adjust isHighlighted to use global indices
                        let isHighlighted = globalCharacterIndex >= globalSelectedCharacterIndex && globalCharacterIndex < globalSelectedCharacterIndex + wordLength
                        CharacterView(isHighlighted: isHighlighted,
                                      character: String(character),
                                      pinyin: pinyin,
                                      characterIndex: characterIndex,
                                      sentenceIndex: sentenceIndex,
                                      isLastCharacter: characterIndex == sentence.mandarinTranslation.count - 1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            Button("Next Chapter") {
                if let story = store.state.storyState.currentStory {
                    if story.chapters.count > story.currentChapterIndex + 1 {
                        store.dispatch(.goToNextChapter)
                    } else if let story = store.state.storyState.currentStory {
                        store.dispatch(.generateChapter(story: story))
                    }
                }
            }
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .id(store.state.viewState.chapterViewId)
    }
}
