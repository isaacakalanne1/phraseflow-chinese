//
//  ChapterListView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 18/10/2024.
//

import SwiftUI

struct ChapterListView: View {
    @EnvironmentObject var store: FastChineseStore
    let story: Story

    var body: some View {

        VStack(spacing: 20) {
            List {
                Section {
                    ForEach(Array(story.chapters.enumerated()), id: \.offset) { (index, chapter) in
                        Button(action: {
                            withAnimation(.easeInOut) {
                                store.dispatch(.selectChapter(story, chapterIndex: index))
                            }
                        }) {
                            Text(chapter.title)
                                .foregroundColor(.primary)
                        }
                    }
                } header: {
                    Text("Chapters")
                }
            }
            Button("New chapter") {
                if let story = store.state.storyState.currentStory {
                    store.dispatch(.generateChapter(story: story))
                    store.dispatch(.updateShowingStoryListView(isShowing: false))
                }
            }
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .navigationTitle("Choose Chapter")
    }

}
