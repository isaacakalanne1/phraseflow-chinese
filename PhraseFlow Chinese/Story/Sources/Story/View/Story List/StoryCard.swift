//
//  StoryCard.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import SwiftUI
import FTColor

struct StoryCard: View {
    @EnvironmentObject var store: FlowTaleStore
    let storyID: UUID

    private var firstChapter: Chapter? {
        store.state.storyState.firstChapter(for: storyID)
    }

    var body: some View {
        NavigationLink(destination: ChapterListView(storyId: storyID)) {
            ZStack {
                // Background image or fallback
                backgroundImage
                
                // Dark overlay for better text readability
                Color.black.opacity(0.2)

                // Story content overlay
                StoryCardOverlay(storyID: storyID)
            }
            .frame(height: 150)
            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .contextMenu {
                DeleteButton {
                    store.dispatch(.storyAction(.deleteStory(storyID)))
                }
            }
        }
    }
    
    private var backgroundImage: some View {
        Group {
            if let image = firstChapter?.coverArt {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                // Fallback gradient background
                LinearGradient(
                    colors: [
                        FTColor.accent.opacity(0.6),
                        FTColor.primary.opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        .frame(height: 150)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
