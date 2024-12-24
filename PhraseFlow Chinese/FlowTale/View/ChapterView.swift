//
//  ChapterView.swift
//  FlowTale
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI

struct ChapterView: View {
    @EnvironmentObject var store: FlowTaleStore
    let chapter: Chapter

    var body: some View {

        if let story = store.state.storyState.currentStory {
            ScrollView(.vertical) {
                ForEach(0...(chapter.timestampData.last?.sentenceIndex ?? 0), id: \.self) { index in
                    let sentenceWords = chapter.timestampData.filter({ $0.sentenceIndex == index })
                    
                    FlowLayout(spacing: 0, language: story.language) {
                        ForEach(Array(sentenceWords.enumerated()), id: \.offset) { index, word in
                            CharacterView(isHighlighted: word == store.state.currentSpokenWord, word: word)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: story.language.alignment)

                Button(LocalizedString.nextChapter) {
                    let doesNextChapterExist = story.chapters.count > story.currentChapterIndex + 1
                    store.dispatch(doesNextChapterExist ? .goToNextChapter : .continueStory(story: story))
                }
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .id(store.state.viewState.chapterViewId)
        }
    }
}
