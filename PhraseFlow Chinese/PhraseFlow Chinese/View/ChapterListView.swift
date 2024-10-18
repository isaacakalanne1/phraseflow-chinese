//
//  ChapterListView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 18/10/2024.
//

import SwiftUI

struct ChapterListView: View {
    @EnvironmentObject var store: FastChineseStore
    let story: Story

    var body: some View {

        VStack(spacing: 20) {
            Spacer()
            Text("Choose a Chapter")
                .font(.title2)

            ScrollView {
                VStack {
                    ForEach(Array(story.chapters.enumerated()), id: \.offset) { (index, chapter) in
                        Button(action: {
                            withAnimation(.easeInOut) {
                                store.dispatch(.selectStory(story))
                            }
                        }) {
                            Text("Chapter \(index + 1)")
                                .bold()
                                .font(.body)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
        .toolbar(.hidden)
        .padding(.horizontal)
    }

}

