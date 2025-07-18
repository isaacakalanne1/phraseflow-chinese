//
//  StoryListView.swift
//  FlowTale
//
//  Created by iakalann on 18/10/2024.
//

import SwiftUI
import FTFont
import FTColor

struct StoryListView: View {
    @EnvironmentObject var store: FlowTaleStore
    @State private var showCreateStorySettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            if store.state.storyState.allStories.isEmpty {
                StoryListEmptyState()
            } else {
                StoryListContent()
            }

            PrimaryButton(
                icon: {
                    Image(systemName: "plus")
                        .font(.flowTaleBodySmall())
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
        .navigationTitle(ContentTab.storyList.title)
        .navigationDestination(isPresented: $showCreateStorySettings) {
            CreateStorySettingsView()
                .background(FTColor.background)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
