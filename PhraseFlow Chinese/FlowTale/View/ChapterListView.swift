//
//  ChapterListView.swift
//  FlowTale
//
//  Created by iakalann on 18/10/2024.
//

import SwiftUI

struct ChapterListView: View {
    @EnvironmentObject var store: FlowTaleStore
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
                    Text(LocalizedString.chapters)
                }
            }
            Button(LocalizedString.newChapter) {
                if let story = store.state.storyState.currentStory {
                    store.dispatch(.continueStory(story: story))
                    store.dispatch(.updateShowingStoryListView(isShowing: false))
                }
            }
            .padding()
            .background(FlowTaleColor.accent)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .navigationTitle(LocalizedString.chooseChapter)
    }

}
