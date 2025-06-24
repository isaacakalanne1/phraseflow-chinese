//
//  StoryCardOverlay.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import SwiftUI

struct StoryCardOverlay: View {
    @EnvironmentObject var store: FlowTaleStore
    let storyID: UUID
    
    private var firstChapter: Chapter? {
        store.state.storyState.firstChapter(for: storyID)
    }
    
    private var allChaptersForStory: [Chapter] {
        store.state.storyState.storyChapters[storyID] ?? []
    }
    
    var body: some View {
        // Content overlay
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            // Bottom section with story details
            VStack(alignment: .leading, spacing: 8) {
                // Story title
                Text(firstChapter?.storyTitle ?? "")
                    .font(.title2.bold())
                    .foregroundColor(FlowTaleColor.primary)
                    .lineLimit(2)
                    .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)

                // Language and difficulty indicators
                languageAndDifficultyIndicators

                // Story summary
                Text(firstChapter?.chapterSummary ?? "")
                    .font(.subheadline)
                    .foregroundColor(FlowTaleColor.primary)
                    .lineLimit(2)
                    .shadow(color: .black, radius: 4, x: 0, y: 0)

                // Chapters count
                chaptersCount
            }
            .padding(16)
        }
    }
    
    private var languageAndDifficultyIndicators: some View {
        HStack(spacing: 12) {
            // Language indicator
            HStack(spacing: 6) {
                Text(firstChapter?.language.flagEmoji ?? "")
                    .font(.title3)

                Text(firstChapter?.language.descriptiveEnglishName ?? "")
                    .font(.caption.weight(.medium))
                    .foregroundColor(FlowTaleColor.primary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(.thinMaterial)
                    .opacity(0.8)
            )
            
            // Difficulty indicator
            HStack(spacing: 8) {
                DifficultyView(difficulty: firstChapter?.difficulty ?? .beginner, isSelected: true)

                Text(firstChapter?.difficulty.title ?? "")
                    .font(.caption.weight(.medium))
                    .foregroundColor(FlowTaleColor.primary)
                    .tracking(0.5)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(.thinMaterial)
                    .opacity(0.8)
            )
        }
    }
    
    private var chaptersCount: some View {
        HStack(spacing: 4) {
            Image(systemName: "book.pages")
                .font(.caption)
                .foregroundColor(FlowTaleColor.primary)

            Text("\(allChaptersForStory.count) \(allChaptersForStory.count == 1 ? "chapter" : "chapters")")
                .font(.caption)
                .foregroundColor(FlowTaleColor.primary)
        }
        .shadow(color: .black, radius: 4, x: 0, y: 0)
    }
}
