//
//  ChapterHeaderView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 19/12/2024.
//

import SwiftUI

struct ChapterHeaderView: View {
    @EnvironmentObject var store: FastChineseStore
    let chapter: Chapter

    var body: some View {
        let chapterNumber = (store.state.storyState.currentStory?.currentChapterIndex ?? 0) + 1

        VStack {
            Text(store.state.storyState.currentStory?.title ?? "")
                .fontWeight(.medium)
            Text(LocalizedString.chapterNumber(String(chapterNumber)) + ": " + chapter.title)
                .fontWeight(.light)
        }
        .greyBackground()
    }
}
