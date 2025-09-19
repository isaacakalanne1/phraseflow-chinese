//
//  StoryListView.swift
//  FlowTale
//
//  Created by iakalann on 18/10/2024.
//

import SwiftUI
import FTColor
import FTStyleKit
import Localization
import ReduxKit

struct StoryListView: View {
    @EnvironmentObject var store: StoryStore
    
    var body: some View {
        VStack {
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
        .background(FTColor.background.color)
        .toolbar(.hidden)
        .navigationBarTitleDisplayMode(.inline)
    }
}
