//
//  ChapterListView.swift
//  FlowTale
//
//  Created by iakalann on 18/10/2024.
//

import SwiftUI

struct ChapterListView: View {
    @EnvironmentObject var store: FlowTaleStore
    let story: Story

    /// Local loading state for chapters
    @State private var isLoadingChapters = false

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
            if story.chapters.isEmpty && isLoadingChapters {
                ProgressView("Loading chapters...")
                    .frame(maxHeight: .infinity)
            } else {
                // MARK: - Chapters List
                List {
                    Section {
                        ForEach(Array(story.chapters.reversed().enumerated()), id: \.offset) { (index, chapter) in
                            Button {
                                withAnimation(.easeInOut) {
                                    store.dispatch(.playSound(.openChapter))
                                    // Convert reversed() index back to original:
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
            }

            // MARK: - "New Chapter" Button
            Button(LocalizedString.newChapter) {
                store.dispatch(.selectTab(.reader, shouldPlaySound: false))
                store.dispatch(.continueStory(story: story))
                store.dispatch(.playSound(.createStory))
                store.dispatch(.updateShowingStoryListView(isShowing: false))
            }
            .padding()
            .background(FlowTaleColor.accent)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .navigationTitle(LocalizedString.chooseChapter)
        .background(FlowTaleColor.background)
        .scrollContentBackground(.hidden)

        // MARK: - onAppear
        .onAppear {
            store.dispatch(.playSound(.openStory))
            // If the chapters are empty, start loading
            if story.chapters.isEmpty {
                isLoadingChapters = true
                store.dispatch(.loadChapters(story))
            }
        }
        // MARK: - Detect When Chapters Come In
        .onChange(of: story.chapters) { newChapters in
            // Once the store updates `story.chapters`, turn off the spinner
            // (Even if still empty, you might want to hide the spinner to indicate "No chapters.")
            isLoadingChapters = false
        }
    }
}
