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
            VStack(spacing: 0) {
                // Header with cover image
                GeometryReader { proxy in
                    Group {
                        if let image = story.coverArt {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: proxy.size.width / 2)
                                .clipShape(RoundedRectangle(cornerRadius: 0))
                        } else {
                            ZStack {
                                Rectangle()
                                    .fill(FlowTaleColor.secondary.opacity(0.1))
                                
                                Image(systemName: "book.closed.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(FlowTaleColor.secondary.opacity(0.5))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(height: 200)

                // Story info section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(story.title)
                            .font(.headline)
                            .foregroundColor(FlowTaleColor.primary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            DifficultyView(difficulty: story.difficulty, isSelected: true)
                            Text(story.difficulty.title)
                                .font(.caption)
                                .foregroundColor(FlowTaleColor.secondary)
                        }
                    }
                    
                    Text(story.briefLatestStorySummary)
                        .font(.subheadline)
                        .foregroundColor(FlowTaleColor.primary.opacity(0.8))
                        .lineLimit(3)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)

                // Chapters section
                ScrollView {
                    LazyVStack(spacing: 12) {
                        HStack {
                            Text(LocalizedString.chapters)
                                .font(.headline)
                                .foregroundColor(FlowTaleColor.secondary)
                            
                            Spacer()
                            
                            if store.state.viewState.loadingState != .complete {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        
                        if story.chapters.isEmpty && store.state.viewState.loadingState == .complete {
                            emptyChaptersView
                        } else {
                            ForEach(Array(story.chapters.reversed().enumerated()), id: \.offset) { index, chapter in
                                chapterCard(for: chapter, at: index, in: story)
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, 100) // Space for button
                }
                
                // New Chapter button floating at the bottom
                VStack {
                    PrimaryButton(
                        icon: {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .semibold))
                        },
                        title: LocalizedString.newChapter
                    ) {
                        store.dispatch(.showSnackBar(.writingChapter))
                        store.dispatch(.createChapter(.existingStory(story)))
                    }
                    .disabled(store.state.viewState.isWritingChapter)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .shadow(color: FlowTaleColor.accent.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .background(
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    FlowTaleColor.background.opacity(0),
                                    FlowTaleColor.background
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 100)
                        .offset(y: -50)
                )
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
            // If no story found in store, show message
            Text(LocalizedString.chapterListStoryNotFound)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(FlowTaleColor.background)
        }
    }
    
    // Empty state when there are no chapters
    private var emptyChaptersView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 50))
                .foregroundColor(FlowTaleColor.accent.opacity(0.6))
                .padding(.top, 20)
            
            Text(LocalizedString.noChaptersYet)
                .font(.headline)
                .foregroundColor(FlowTaleColor.primary)
            
            Text(LocalizedString.createYourFirstChapter)
                .font(.subheadline)
                .foregroundColor(FlowTaleColor.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
    
    // Individual chapter card
    private func chapterCard(for chapter: Chapter, at index: Int, in story: Story) -> some View {
        Button {
            withAnimation(.easeInOut) {
                store.dispatch(.playSound(.openChapter))
                let chapterIndex = story.chapters.count - 1 - index
                store.dispatch(.selectChapter(story, chapterIndex: chapterIndex))
            }
        } label: {
            HStack(spacing: 12) {
                // Chapter number indicator
                ZStack {
                    Circle()
                        .fill(FlowTaleColor.accent.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Text("\(story.chapters.count - index)")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(FlowTaleColor.accent)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(chapter.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(FlowTaleColor.primary)
                        .lineLimit(1)
                    
                    // Display a snippet of the chapter's content
                    let snippetText = chapter.sentences.prefix(1).map { $0.original }.first ?? ""
                    if !snippetText.isEmpty {
                        Text(snippetText)
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(FlowTaleColor.secondary)
                            .lineLimit(2)
                    }
                }
                .padding(.vertical, 10)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(FlowTaleColor.secondary)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(FlowTaleColor.background)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
            .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}
