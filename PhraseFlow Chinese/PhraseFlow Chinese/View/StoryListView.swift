//
//  StoryListView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 18/10/2024.
//

import SwiftUI

struct StoryListView: View {
    @EnvironmentObject var store: FastChineseStore

    var body: some View {

        NavigationView {
            VStack {
                List {
                    ForEach(store.state.savedStories, id: \.self) { story in
                        HStack {
                            NavigationLink(destination: ChapterListView(story: story)) {
                                VStack(alignment: .leading, content: {
                                    Text(story.title)
                                        .fontWeight(.medium)
                                    Text(story.latestStorySummary)
                                        .fontWeight(.light)
                                })
                                .padding(.trailing)
                            }
                        }
                        .foregroundStyle(Color.primary)
                    }
                    .onDelete(perform: delete)
                }
                Button("Create") {
                    let genres = Array(Genre.allCases.shuffled().prefix(3))
                    store.dispatch(.generateNewStory(genres: genres))
                }
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .toolbar(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Choose Story")
        }
        .onAppear {
            store.dispatch(.loadStories)
        }
    }

    func delete(at offsets: IndexSet) {
        guard let index = offsets.first,
              let story = store.state.savedStories[safe: index] else { return }
        store.dispatch(.deleteStory(story))
    }

}
