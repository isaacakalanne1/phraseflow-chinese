//
//  CreateStoryButton.swift
//  FlowTale
//
//  Created by iakalann on 18/04/2025.
//

import SwiftUI
import Localization
import ReduxKit
import FTStyleKit
import Audio

public struct CreateStoryButton: View {
    @EnvironmentObject var store: StoryStore
    
    public init() {}

    public var body: some View {
        MainButton(title: LocalizedString.newStory.uppercased()) {
            store.dispatch(.playSound(.largeBoom))
            store.dispatch(.createChapter(.newStory))
        }
        .disabled(store.state.viewState.isWritingChapter)
    }
}
