//
//  StoryListView.swift
//  FlowTale
//
//  Created by iakalann on 18/10/2024.
//

import SwiftUI

struct StoryListView: View {
    @EnvironmentObject var store: FlowTaleStore
    @State private var showCreateStorySettings = false

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section {
                        ForEach(store.state.storyState.savedStories.filter { $0.isShown }, id: \.self) { story in
                            NavigationLink(destination: ChapterListView(storyId: story.id)) {
                                VStack(alignment: .leading, content: {
                                    HStack {
                                        Group {
                                            if let image = story.coverArt {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 100, height: 100)
                                                    .clipped()
                                                    .clipShape(RoundedRectangle(cornerSize: .init(width: 10, height: 10)))
                                            } else {
                                                Text("")
                                                    .frame(width: 100, height: 100)
                                            }
                                        }
                                        VStack(alignment: .leading, spacing: 0) {
                                            HStack {
                                                StoryInfoView(story: story)
                                                Text(story.title)
                                                    .fontWeight(.medium)
                                                    .frame(height: 30)
                                            }
                                            Text(story.briefLatestStorySummary)
                                                .fontWeight(.light)
                                                .frame(height: 70)
                                        }
                                    }
                                })
                            }
                            .foregroundStyle(FlowTaleColor.primary)
                        }
                        .onDelete(perform: delete)
                    } header: {
                        Text(LocalizedString.stories)
                    }
                }
                
                // New Story button at the bottom
                PrimaryButton(
                    icon: {
                        Image(systemName: "plus")
                            .font(.headline)
                    },
                    title: LocalizedString.createStory
                ) {
                    showCreateStorySettings = true
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .toolbar(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(ContentTab.storyList.title)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(FlowTaleColor.background)
            .scrollContentBackground(.hidden)
            .navigationDestination(isPresented: $showCreateStorySettings) {
                CreateStorySettingsView()
                    .background(FlowTaleColor.background)
            }
        }
        .id(store.state.viewState.storyListViewId)
    }

    func delete(at offsets: IndexSet) {
        // Get only visible stories
        let visibleStories = store.state.storyState.savedStories.filter { $0.isShown }
        
        // Get the story from the visible stories array using the offset
        guard let index = offsets.first,
              let story = visibleStories[safe: index] else { return }
        
        store.dispatch(.deleteStory(story))
    }

}
