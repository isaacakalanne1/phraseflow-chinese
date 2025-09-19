//
//  ChapterHeaderView.swift
//  Story
//
//  Created by Isaac Akalanne on 02/09/2025.
//

import FTColor
import FTFont
import SwiftUI
import TextGeneration

struct ChapterHeaderView: View {
    @EnvironmentObject var store: TextPracticeStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                StoryInfoView(chapter: store.state.chapter)
                
                Text(store.state.chapter.storyTitle)
                    .font(FTFont.flowTaleSecondaryHeader())
                    .foregroundColor(FTColor.primary.color)
                    .lineLimit(1)
            }
            
            Text(store.state.chapter.title)
                .font(FTFont.flowTaleSecondaryHeader())
                .foregroundColor(FTColor.primary.color.opacity(0.9))
                .lineLimit(1)
        }
    }
}
