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
                                    .foregroundStyle(Color.primary)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity)
                                }
                                NavigationLink(destination: ChapterListView(story: story)) {
                                    Image(systemName: "chevron.right")
                                        .frame(width: 50, height: 100)
                                        .foregroundStyle(Color.accentColor)
                                }
                            }
                        }
                    }
                }
            }
            .toolbar(.hidden)
            .padding(.horizontal)
            .padding(.top, 20)
        }
        .onAppear {
            store.dispatch(.loadStories)
        }
        .navigationTitle("Choose Story")
    }

}
