//
//  ChapterHeaderView.swift
//  Story
//
//  Created by Isaac Akalanne on 02/09/2025.
//

import FTColor
import FTFont
import SwiftUI

struct ChapterHeaderView: View {
    @EnvironmentObject var store: TextPracticeStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let chapter = store.state.currentChapter {
                HStack(spacing: 12) {
                    StoryInfoView(chapter: chapter)
                    
                    Text(chapter.storyTitle)
                        .font(FTFont.flowTaleSecondaryHeader())
                        .foregroundColor(FTColor.primary)
                        .lineLimit(1)
                }
                
                Text(chapter.title)
                    .font(FTFont.flowTaleSecondaryHeader())
                    .foregroundColor(FTColor.primary.opacity(0.9))
                    .lineLimit(1)
            }
        }
    }
}
