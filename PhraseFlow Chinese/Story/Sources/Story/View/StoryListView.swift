//
//  StoryListView.swift
//  FlowTale
//
//  Created by iakalann on 18/10/2024.
//

import SwiftUI
import FTFont
import FTColor
import FTStyleKit
import TextGeneration
import Localization
import Settings
import ReduxKit

struct StoryListView: View {
    @EnvironmentObject var store: StoryStore
    @State private var showCreateStorySettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            if store.state.allStories.isEmpty {
                StoryListEmptyState()
            } else {
                StoryListContent()
            }
            
            MainButton(title: LocalizedString.newStory.uppercased()) {
                DispatchQueue.main.async {
                    store.dispatch(.createChapter(.newStory))
                }
            }
            .disabled(store.state.isWritingChapter)
            .frame(maxWidth: .infinity)
            .padding([.horizontal, .bottom])
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColor.background)
        .navigationTitle(LocalizedString.stories)
        .navigationDestination(isPresented: $showCreateStorySettings) {
            CreateStorySettingsView()
                .background(FTColor.background)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
