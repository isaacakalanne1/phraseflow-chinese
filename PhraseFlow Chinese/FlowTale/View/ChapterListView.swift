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

    // A computed property that looks up the current story from the store.
    // If it's not found, this can be nil (or handle accordingly).
    private var story: Story? {
        store.state.storyState.savedStories.first(where: { $0.id == storyId })
    }

    var body: some View {
        // We can unwrap the story or show an error/empty view if not found
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
                        DifficultyView(difficulty: story.difficulty)
                        Text(story.difficulty.title.uppercased())
                            .font(.system(size: 15, weight: .ultraLight))
                    }
                    Text(story.briefLatestStorySummary)
                        .font(.system(size: 15, weight: .light))
                }
                .padding()

                // MARK: - Show Spinner if We're Loading & No Chapters Yet
                List {
                    Section {
                        ForEach(Array(story.chapters.reversed().enumerated()), id: \.offset) { (index, chapter) in
                            Button {
                                withAnimation(.easeInOut) {
                                    store.dispatch(.playSound(.openChapter))
                                    let chapterIndex = story.chapters.count - 1 - index
                                    store.dispatch(.selectChapter(story, chapterIndex: chapterIndex))
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

                Group {
                    if story.chapters.count >= 20 {
                        PrimaryButton(title: LocalizedString.newChapter) {
                            store.dispatch(.selectTab(.reader, shouldPlaySound: false))
                            store.dispatch(.createChapter(.existingStory(story)))
                            store.dispatch(.playSound(.createStory))
                        }
                    } else {
//                        PrimaryButton(title: "Create Sequel") { // TODO: Localize
//                            store.dispatch(.selectTab(.reader, shouldPlaySound: false))
//                            let sequelId = UUID()
//                            var prequelStory = story
//                            prequelStory.id = UUID()
//                            prequelStory.sequelId = sequelId
//                            store.dispatch(.createChapter(.sequel(story, newId: sequelId)))
//                            store.dispatch(.deleteStory(story))
//                            store.dispatch(.saveStoryAndSettings(prequelStory))
//                            store.dispatch(.playSound(.createStory))
//                        }
                    }
                }
                .padding(.bottom)
                // TODO: Add Settings button to change voice
            }
            .navigationTitle(LocalizedString.chooseChapter)
            .background(FlowTaleColor.background)
            .scrollContentBackground(.hidden)
            .onAppear {
                store.dispatch(.playSound(.openStory))

                // If the chapters are empty, start loading
                if story.chapters.isEmpty {
                    store.dispatch(.loadChapters(story, isAppLaunch: false))
                }
            }
        } else {
            // If no story found in store, show something like:
            Text("Story not found.")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(FlowTaleColor.background)
        }
    }
}
