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
            store.dispatch(.audioAction(.playSound(.largeBoom)))
            store.dispatch(.navigationAction(.selectTab(.reader, shouldPlaySound: false)))
            store.dispatch(.storyAction(.createChapter(.newStory)))
        }
        .disabled(store.state.viewState.isWritingChapter)
    }
}
