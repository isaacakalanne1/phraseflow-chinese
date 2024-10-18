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
                Spacer()
                Text("Choose a Story")
                    .font(.title2)

                ScrollView {
                    VStack {
                        ForEach(store.state.savedStories, id: \.self) { story in
                            Button(action: {
                                withAnimation(.easeInOut) {
                                    store.dispatch(.selectStory(story))
                                }
                            }) {
                                VStack(alignment: .leading, content: {
                                    Text(story.title)
                                        .bold()
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity)
                                        .cornerRadius(10)
                                    Text(story.description)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity)
                                        .cornerRadius(10)
                                })
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
