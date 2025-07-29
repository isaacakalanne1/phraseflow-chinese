//
//  StoryCard.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import SwiftUI
import FTColor
import TextGeneration
import ReduxKit

public struct StoryCard: View {
    @EnvironmentObject var store: StoryStore
    let storyID: UUID
    let onTap: () -> Void
    
    public init(storyID: UUID, onTap: @escaping () -> Void = {}) {
        self.storyID = storyID
        self.onTap = onTap
    }

    private var firstChapter: Chapter? {
        store.state.firstChapter(for: storyID)
    }

    public var body: some View {
        Button(action: onTap) {
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
                    store.dispatch(.deleteStory(storyID))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
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
