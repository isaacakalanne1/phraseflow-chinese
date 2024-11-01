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
            ScrollView {
                ForEach(Array(story.chapters.enumerated()), id: \.offset) { (index, chapter) in
                    Button(action: {
                        withAnimation(.easeInOut) {
                            store.dispatch(.selectChapter(story, chapterIndex: index))
                        }
                    }) {
                        Text("Chapter \(index + 1)")
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(10)
                    }
                }
            }
            Button("Create new chapter") {
                if let chapter = store.state.currentChapter {
                    store.dispatch(.generateChapter(previousChapter: chapter))
                }
            }
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding(.horizontal)
        .navigationTitle("Choose Chapter")
    }

}
