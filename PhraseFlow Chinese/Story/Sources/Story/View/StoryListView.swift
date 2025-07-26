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
                store.dispatch(.createChapter(.newStory))
            }
            .disabled(store.state.isWritingChapter)
            .frame(maxWidth: .infinity)
            .padding([.horizontal, .bottom])

            PrimaryButton(
                icon: {
                    Image(systemName: "plus")
                        .font(FTFont.flowTaleBodySmall())
                },
                title: LocalizedString.createStory
            ) {
                showCreateStorySettings = true
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .shadow(color: FTColor.accent.opacity(0.3), radius: 10, x: 0, y: 5)
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
