//
//  StoryInfoView.swift
//  FlowTale
//
//  Created by iakalann on 26/12/2024.
//

import SwiftUI

struct StoryInfoView: View {
    let chapter: Chapter
    
    init(chapter: Chapter) {
        self.chapter = chapter
    }

    var body: some View {
        HStack {
            DifficultyView(difficulty: chapter.difficulty, isSelected: true)
            Text(chapter.language.flagEmoji)
        }
    }
}
