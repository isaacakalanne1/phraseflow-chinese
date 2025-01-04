//
//  ChapterListView.swift
//  FlowTale
//
//  Created by iakalann on 18/10/2024.
//

import SwiftUI

struct ChapterListView: View {
    @EnvironmentObject var store: FlowTaleStore
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    let story: Story

    var body: some View {

        VStack(spacing: 5) {
            GeometryReader { proxy in
                Group {
                    if let image = story.coverArt {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        EmptyView()
                            .tint(FlowTaleColor.accent)
                    }
                }
                .frame(maxWidth: .infinity, idealHeight: proxy.size.width/2, alignment: .center)
            }
            
            Group {
                HStack {
                    Text(story.title)
                        .font(.system(size: 20, weight: .medium))
                    Spacer()
                    DifficultyView(difficulty: story.difficulty)
                    Text(story.difficulty.title.uppercased())
                        .font(.system(size: 15, weight: .ultraLight))
                }
                Text(story.briefLatestStorySummary)
                    .font(.system(size: 15, weight: .light))
            }
            .padding()
            List {
                Section {
                    ForEach(Array(story.chapters.reversed().enumerated()), id: \.offset) { (index, chapter) in
                        Button(action: {
                            withAnimation(.easeInOut) {
                                store.dispatch(.playSound(.openChapter))
                                store.dispatch(.selectChapter(story, chapterIndex: story.chapters.count - 1 - index))
                            }
                        }) {
                            Text(chapter.title)
                                .foregroundColor(.primary)
                        }
                    }
                } header: {
                    Text(LocalizedString.chapters)
                }
            }
            .frame(maxHeight: .infinity)
            Button(LocalizedString.newChapter) {
                store.dispatch(.continueStory(story: story))
                store.dispatch(.updateShowingStoryListView(isShowing: false))
            }
            .padding()
            .background(FlowTaleColor.accent)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .navigationTitle(LocalizedString.chooseChapter)
        .onAppear {
            store.dispatch(.playSound(.openStory))
        }
    }

}
