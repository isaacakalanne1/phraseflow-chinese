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
        let chapterNumber = (store.state.storyState.currentStory?.currentChapterIndex ?? 0) + 1

        VStack(spacing: 10) {
            if store.state.settingsState.isShowingDefinition {
                DefinitionView()
                    .frame(height: 150)
            }
            if store.state.settingsState.isShowingEnglish {
                EnglishSentenceView()
                    .frame(height: 120)
            }
            HStack(spacing: 0) {
                Text(store.state.storyState.currentStory?.title ?? "")
                    .fontWeight(.medium)
                Text(" ")
                    .fontWeight(.light)
                Text("Chapter \(chapterNumber)")
                    .fontWeight(.light)
            }
            .greyBackground()
            ChapterView(chapter: chapter)
            ActionButtonsView(chapter: chapter)
        }
    }
}
