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
                Text("Choose a Story")
                    .font(.title2)

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
                                            .font(.body)
                                            .foregroundColor(.primary)
                                            .frame(maxWidth: .infinity)
                                            .cornerRadius(10)
                                        Text(story.latestStorySummary)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                            .frame(maxWidth: .infinity)
                                            .cornerRadius(10)
                                    })
                                    .multilineTextAlignment(.leading)
                                    Image(systemName: "play.circle.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundStyle(Color.accentColor)
                                }
                                NavigationLink(destination: ChapterListView(story: story)) {
                                    Image(systemName: "magnifyingglass.circle")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundStyle(Color.accentColor)
                                }
                            }
                        }
                    }
                }
            }
            .toolbar(.hidden)
            .padding(.horizontal)
        }
        .onAppear {
            store.dispatch(.loadStories)
        }
    }

}
