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
            // Check if user has existing stories
            let hasExistingStories = !store.state.storyState.savedStories.isEmpty

            if hasExistingStories {
                // For existing users, show a snackbar with loading and stay on current view
                store.dispatch(.showSnackBar(.writingChapter))
                store.dispatch(.createChapter(.newStory))
            } else {
                // For new users, use the original flow with full screen loading
                store.dispatch(.playSound(.largeBoom))
                store.dispatch(.selectTab(.reader, shouldPlaySound: false))
                store.dispatch(.createChapter(.newStory))
            }
        }
        // Disable button if currently writing a chapter
        .disabled(store.state.viewState.isWritingChapter)
    }
}
