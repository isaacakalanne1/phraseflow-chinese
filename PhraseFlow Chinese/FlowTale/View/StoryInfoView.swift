//
//  StoryInfoView.swift
//  FlowTale
//
//  Created by iakalann on 26/12/2024.
//

import SwiftUI

struct StoryInfoView: View {
    let story: Story?
    let chapter: Chapter?
    
    init(story: Story) {
        self.story = story
        self.chapter = nil
    }
    
    init(chapter: Chapter) {
        self.story = nil
        self.chapter = chapter
    }

    var body: some View {
        HStack {
            if let story = story {
                DifficultyView(difficulty: story.difficulty, isSelected: true)
                Text(story.language.flagEmoji)
            } else if let chapter = chapter {
                DifficultyView(difficulty: chapter.difficulty, isSelected: true)
                Text(chapter.language.flagEmoji)
            }
        }
    }
}
