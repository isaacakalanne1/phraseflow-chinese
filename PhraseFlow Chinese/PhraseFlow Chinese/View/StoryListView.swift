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
            VStack(spacing: 20) {
                ScrollView {
                    VStack {
                        ForEach(store.state.savedStories, id: \.self) { story in
                            HStack {
                                Button {
                                    store.dispatch(.selectStory(story))
                                } label: {
                                    VStack(alignment: .leading, content: {
                                        Text(story.title)
                                            .bold()
                                        Text(story.latestStorySummary)
                                            .fontWeight(.light)
                                    })
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity)
                                }
                                NavigationLink(destination: ChapterListView(story: story)) {
                                    Image(systemName: "chevron.right")
                                        .frame(width: 60, height: 100)
                                }
                            }
                            .foregroundStyle(Color.primary)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .toolbar(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Choose Story")
        }
        .onAppear {
            store.dispatch(.loadStories)
        }
    }

}
