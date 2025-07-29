//
//  StoryListContent.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import SwiftUI
import FTFont
import FTColor
import Localization
import ReduxKit

struct StoryListContent: View {
    @EnvironmentObject var store: StoryStore
    @State private var swipeOffsets: [UUID: CGFloat] = [:]
    @State private var showingDeleteButtons: Set<UUID> = []
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                Text(LocalizedString.stories)
                    .font(FTFont.flowTaleSecondaryHeader())
                    .foregroundColor(FTColor.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                
                ForEach(store.state.allStories, id: \.storyId) { storyInfo in
                    SwipeToDeleteRow(
                        storyID: storyInfo.storyId,
                        swipeOffset: swipeOffsets[storyInfo.storyId] ?? 0,
                        showingDelete: showingDeleteButtons.contains(storyInfo.storyId)
                    ) {
                        StoryCard(storyID: storyInfo.storyId)
                    } onSwipeChanged: { offset in
                        swipeOffsets[storyInfo.storyId] = offset
                        if offset < -50 {
                            showingDeleteButtons.insert(storyInfo.storyId)
                        } else if offset > -20 {
                            showingDeleteButtons.remove(storyInfo.storyId)
                        }
                    } onDelete: {
                        store.dispatch(.deleteStory(storyInfo.storyId))
                        swipeOffsets.removeValue(forKey: storyInfo.storyId)
                        showingDeleteButtons.remove(storyInfo.storyId)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 100) // Extra space at bottom for the create button
        }
    }
}

struct SwipeToDeleteRow<Content: View>: View {
    let storyID: UUID
    let swipeOffset: CGFloat
    let showingDelete: Bool
    let content: Content
    let onSwipeChanged: (CGFloat) -> Void
    let onDelete: () -> Void
    
    init(
        storyID: UUID,
        swipeOffset: CGFloat,
        showingDelete: Bool,
        @ViewBuilder content: () -> Content,
        onSwipeChanged: @escaping (CGFloat) -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.storyID = storyID
        self.swipeOffset = swipeOffset
        self.showingDelete = showingDelete
        self.content = content()
        self.onSwipeChanged = onSwipeChanged
        self.onDelete = onDelete
    }
    
    var body: some View {
        HStack(spacing: 0) {
            content
                .offset(x: swipeOffset)
            
            if showingDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .transition(.move(edge: .trailing))
            }
        }
        .clipped()
        .gesture(
            DragGesture()
                .onChanged { value in
                    let translation = value.translation.width
                    if translation < 0 {
                        onSwipeChanged(max(translation, -80))
                    } else if swipeOffset < 0 {
                        onSwipeChanged(min(0, swipeOffset + translation))
                    }
                }
                .onEnded { value in
                    let translation = value.translation.width
                    if translation < -50 {
                        onSwipeChanged(-80)
                    } else {
                        onSwipeChanged(0)
                    }
                }
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: swipeOffset)
    }
}
