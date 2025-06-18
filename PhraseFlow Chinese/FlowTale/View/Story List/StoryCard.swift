//
//  StoryCard.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import SwiftUI

struct StoryCard: View {
    @EnvironmentObject var store: FlowTaleStore
    let story: Story
    
    var body: some View {
        NavigationLink(destination: ChapterListView(storyId: story.id)) {
            ZStack {
                // Background image or fallback
                backgroundImage
                
                // Dark overlay for better text readability
                Color.black.opacity(0.2)

                // Story content overlay
                StoryCardOverlay(story: story)
            }
            .frame(height: 150)
            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .contextMenu {
                DeleteButton {
                    store.dispatch(.storyAction(.deleteStory(story)))
                }
            }
        }
    }
    
    private var backgroundImage: some View {
        Group {
            if let image = story.coverArt {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                // Fallback gradient background
                LinearGradient(
                    colors: [
                        FlowTaleColor.accent.opacity(0.6),
                        FlowTaleColor.primary.opacity(0.8)
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
