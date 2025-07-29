//
//  StoryListContent.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import SwiftUI
import FTFont
import FTColor
import Localization
import ReduxKit

struct StoryListContent: View {
    @EnvironmentObject var store: StoryStore
    @State private var selectedStoryID: UUID?
    
    var body: some View {
        List {
            Section {
                ForEach(store.state.allStories, id: \.storyId) { storyInfo in
                    StoryCard(storyID: storyInfo.storyId) {
                        selectedStoryID = storyInfo.storyId
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let storyToDelete = store.state.allStories[index]
                        store.dispatch(.deleteStory(storyToDelete.storyId))
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .navigationDestination(isPresented: Binding<Bool>(
            get: { selectedStoryID != nil },
            set: { if !$0 { selectedStoryID = nil } }
        )) {
            if let storyId = selectedStoryID {
                ChapterListView(storyId: storyId)
                    .environmentObject(store)
            }
        }
    }
}
