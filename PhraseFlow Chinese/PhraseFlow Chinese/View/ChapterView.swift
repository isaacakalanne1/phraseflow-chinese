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

        let chapterIndex = store.state.storyState.currentStory?.currentChapterIndex ?? 0
        let chapter = store.state.storyState.currentStory?.chapters[safe: chapterIndex]

        ScrollView(.vertical) {

            ForEach(0...(chapter?.timestampData.last?.sentenceIndex ?? 1), id: \.self) { index in
                FlowLayout(spacing: 0,
                           language: store.state.storyState.currentStory?.language) {
                    let sentenceWords = chapter?.timestampData.filter({ $0.sentenceIndex == index }) ?? []
                    ForEach(Array(sentenceWords.enumerated()), id: \.offset) { index, word in
                        CharacterView(isHighlighted: word == store.state.currentSpokenWord, word: word)
                    }
                }

            }

                       .frame(maxWidth: .infinity, alignment: store.state.storyState.currentStory?.language == .arabicGulf ? .trailing : .leading)
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
