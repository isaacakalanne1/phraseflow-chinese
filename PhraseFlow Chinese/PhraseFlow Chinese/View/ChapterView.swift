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

        // Compute the global index of the selected character
        let wordLength = currentSpokenWord?.wordLength ?? 1
        let globalSelectedCharacterIndex = cumulativeCharacterCounts(language: store.state.storyState.currentStory?.language)[selectedSentenceIndex] + selectedCharacterIndex

        ScrollView(.vertical) {
            ForEach(Array(chapter.sentences.enumerated()), id: \.element) { (sentenceIndex, sentence) in
                let cumulativeSentenceStartIndex = cumulativeCharacterCounts(language: store.state.storyState.currentStory?.language)[sentenceIndex]
                let sentenceList: Array<String> = store.state.storyState.currentStory?.language == .arabicGulf ? sentence.convertedTranslation : sentence.translation.map( { String($0) })

                FlowLayout(spacing: 0,
                           language: store.state.storyState.currentStory?.language) {
                    ForEach(Array(sentenceList.enumerated()), id: \.offset) { characterIndex, character in
                        // Compute the global character index
                        let globalCharacterIndexForEntry = cumulativeSentenceStartIndex + characterIndex

                        // Adjust isHighlighted to use global indices
                        let isHighlighted = globalCharacterIndexForEntry >= globalSelectedCharacterIndex && globalCharacterIndexForEntry < globalSelectedCharacterIndex + wordLength
                        CharacterView(isHighlighted: isHighlighted,
                                      character: character,
                                      characterIndex: characterIndex,
                                      sentenceIndex: sentenceIndex,
                                      isLastCharacter: characterIndex == sentence.translation.count - 1)
                    }
                }
                           .frame(maxWidth: .infinity,
                                  alignment: store.state.storyState.currentStory?.language == .arabicGulf ? .trailing : .leading)
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

    func cumulativeCharacterCounts(language: Language?) -> [Int] {
        var counts: [Int] = []
        var cumulativeCount = 0
        for sentence in chapter.sentences {
            counts.append(cumulativeCount)
            cumulativeCount += language == .arabicGulf ? sentence.convertedTranslation.count : sentence.translation.count
        }
        return counts
    }
}
