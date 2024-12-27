//
//  ChapterHeaderView.swift
//  FlowTale
//
//  Created by iakalann on 19/12/2024.
//

import SwiftUI

struct ChapterHeaderView: View {
    @EnvironmentObject var store: FlowTaleStore
    let chapter: Chapter

    var body: some View {
        VStack {
            Group {
                if let story = store.state.storyState.currentStory {
                    HStack {
                        StoryInfoView(story: story)
                        Text(story.title)
                            .fontWeight(.medium)
                    }
                }
                Text(chapter.title)
                    .fontWeight(.light)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .greyBackground()
    }
}
