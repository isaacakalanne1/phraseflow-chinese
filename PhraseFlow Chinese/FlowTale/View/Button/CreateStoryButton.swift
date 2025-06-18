//
//  CreateStoryButton.swift
//  FlowTale
//
//  Created by iakalann on 18/04/2025.
//

import SwiftUI

struct CreateStoryButton: View {
    @EnvironmentObject var store: FlowTaleStore

    var body: some View {
        MainButton(title: LocalizedString.newStory.uppercased()) {
            let hasExistingStories = !store.state.storyState.savedStories.isEmpty

            if hasExistingStories {
                store.dispatch(.showSnackBar(.writingChapter))
                store.dispatch(.storyAction(.createChapter(.newStory)))
            } else {
                store.dispatch(.audioAction(.playSound(.largeBoom)))
                store.dispatch(.selectTab(.reader, shouldPlaySound: false))
                store.dispatch(.storyAction(.createChapter(.newStory)))
            }
        }
        // Disable button if currently writing a chapter
        .disabled(store.state.viewState.isWritingChapter)
    }
}
