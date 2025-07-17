//
//  StoryListContent.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import SwiftUI

struct StoryListContent: View {
    @EnvironmentObject var store: FlowTaleStore
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                Text(LocalizedString.stories)
                    .font(.flowTaleSecondaryHeader())
                    .foregroundColor(FTColor.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                
                ForEach(store.state.storyState.allStories, id: \.storyId) { storyInfo in
                    StoryCard(storyID: storyInfo.storyId)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 100) // Extra space at bottom for the create button
        }
    }
}
