//
//  ChapterListView.swift
//  FlowTale
//
//  Created by iakalann on 18/10/2024.
//

import SwiftUI

struct ChapterListView: View {
    @EnvironmentObject var store: FlowTaleStore
    let storyId: UUID

    private var story: Story? {
        store.state.storyState.savedStories.first(where: { $0.id == storyId })
    }

    var body: some View {
        if let story = story {
            VStack(spacing: 5) {
                GeometryReader { proxy in
                    Group {
                        if let image = story.coverArt {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            EmptyView()
                        }
                    }
                    .frame(
                        maxWidth: .infinity,
                        idealHeight: proxy.size.width / 2,
                        alignment: .center
                    )
                }

                Group {
                    HStack {
                        Text(story.title)
                            .font(.system(size: 20, weight: .medium))
                        Spacer()
                        DifficultyView(difficulty: story.difficulty, isSelected: true)
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
                            Button {
                                withAnimation(.easeInOut) {
                                    store.dispatch(.playSound(.openChapter))
                                    let chapterIndex = story.chapters.count - 1 - index
                                    store.dispatch(.storyAction(.selectChapter(story, chapterIndex: chapterIndex)))
                                }
                            } label: {
                                Text(chapter.title)
                                    .foregroundColor(.primary)
                            }
                        }
                    } header: {
                        Text(LocalizedString.chapters)
                    }
                }
                .frame(maxHeight: .infinity)

                MainButton(title: LocalizedString.newChapter.uppercased()) {
                    store.dispatch(.snackBarAction(.showSnackBar(.writingChapter)))
                    store.dispatch(.storyAction(.createChapter(.existingStory(story))))
                }
                .disabled(store.state.storyState.isCreatingChapter)
                .padding()
                // TODO: Add Settings button to change voice
            }
            .navigationTitle(LocalizedString.chooseChapter)
            .background(FlowTaleColor.background)
            .scrollContentBackground(.hidden)
            .onAppear {
                store.dispatch(.playSound(.openStory))

                if story.chapters.isEmpty {
                    store.dispatch(.storyAction(.loadChapters(story, isAppLaunch: false)))
                }
            }
        } else {
            Text(LocalizedString.chapterListStoryNotFound)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(FlowTaleColor.background)
        }
    }
}
