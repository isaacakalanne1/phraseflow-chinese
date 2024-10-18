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
                                store.dispatch(.selectChapter(index))
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
                Button(action: {
                    withAnimation(.easeInOut) {
                        store.dispatch(.generateNewChapter(story: story))
                    }
                }) {
                    Text("Create new chapter")
                        .bold()
                        .font(.body)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal)
    }

}
