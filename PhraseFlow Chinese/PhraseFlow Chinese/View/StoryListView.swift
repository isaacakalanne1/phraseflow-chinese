//
//  StoryListView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 18/10/2024.
//

import SwiftUI

struct StoryListView: View {
    @EnvironmentObject var store: FlowTaleStore

    var body: some View {

        NavigationView {
            VStack {
                List {
                    Section {
                        ForEach(store.state.storyState.savedStories, id: \.self) { story in
                            HStack {
                                NavigationLink(destination: ChapterListView(story: story)) {
                                    VStack(alignment: .leading, content: {
                                        Text(story.title)
                                            .fontWeight(.medium)
                                        Text(story.briefLatestStorySummary)
                                            .fontWeight(.light)
                                    })
                                    .padding(.trailing)
                                }
                            }
                            .foregroundStyle(Color.primary)
                        }
                        .onDelete(perform: delete)
                    } header: {
                        Text(LocalizedString.stories)
                    }
                }
                Button("\(store.state.settingsState.language.flagEmoji) \(LocalizedString.newStory) (\(store.state.settingsState.difficulty.title))") {
                    store.dispatch(.continueStory(story: store.state.createNewStory()))
                }
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
                NavigationLink(destination: CreateStorySettingsView()) {
                    Text(LocalizedString.settings)
                        .frame(height: 40)
                }
                .foregroundColor(.accentColor)
            }
            .toolbar(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(LocalizedString.chooseStory)
        }
        .onAppear {
            store.dispatch(.loadStories)
        }
        .id(store.state.viewState.storyListViewId)
    }

    func delete(at offsets: IndexSet) {
        guard let index = offsets.first,
              let story = store.state.storyState.savedStories[safe: index] else { return }
        store.dispatch(.deleteStory(story))
    }

}
