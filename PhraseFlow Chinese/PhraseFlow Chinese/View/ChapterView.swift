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
        ScrollView(.vertical) {
            ForEach(Array(chapter.sentences.enumerated()), id: \.element) { (sentenceIndex, sentence) in
                FlowLayout(spacing: 0) {
                    ForEach(Array(sentence.mandarin.enumerated()), id: \.offset) { characterIndex, element in
                        let character = sentence.mandarin[characterIndex]
                        let pinyin = sentence.pinyin.count > characterIndex ? sentence.pinyin[characterIndex] : ""
                        let isHighlighted = sentenceIndex == selectedSentenceIndex && characterIndex >= selectedCharacterIndex && characterIndex < selectedCharacterIndex + (currentSpokenWord?.wordLength ?? 1)
                        CharacterView(isHighlighted: isHighlighted,
                                      character: character,
                                      pinyin: pinyin,
                                      characterIndex: characterIndex,
                                      sentenceIndex: sentenceIndex)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            Button("Next Chapter") {
                if let story = store.state.currentStory {
                    if story.chapters.count > story.currentChapterIndex + 1 {
                        store.dispatch(.goToNextChapter)
                    } else if let chapter = store.state.currentChapter {
                        store.dispatch(.generateChapter(previousChapter: chapter))
                    }
                }
            }
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}
