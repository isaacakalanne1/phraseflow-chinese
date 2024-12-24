//
//  ChapterHeaderView.swift
//  PhraseFlow Chinese
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
                Text(store.state.storyState.currentStory?.title ?? "")
                    .fontWeight(.medium)
                Text(chapter.title)
                    .fontWeight(.light)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .greyBackground()
    }
}
