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
                        ForEach(store.state.storyState.savedStories, id: \.self) { story in
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
            .navigationTitle(LocalizedString.chooseStory)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(FlowTaleColor.background)
            .scrollContentBackground(.hidden)
            .navigationDestination(isPresented: $showCreateStorySettings) {
                NavigationStack {
                    CreateStorySettingsView()
                        .background(FlowTaleColor.background)
                }
            }
        }
        .id(store.state.viewState.storyListViewId)
    }

    func delete(at offsets: IndexSet) {
        guard let index = offsets.first,
              let story = store.state.storyState.savedStories[safe: index] else { return }
        store.dispatch(.deleteStory(story))
    }

}
