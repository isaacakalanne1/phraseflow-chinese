//
//  StoryInfoView.swift
//  FlowTale
//
//  Created by iakalann on 26/12/2024.
//

import FTStyleKit
import SwiftUI
import TextGeneration

struct StoryInfoView: View {
    let chapter: Chapter

    var body: some View {
        HStack {
            DifficultyView(difficultyIndex: chapter.difficulty.index)
            Text(chapter.language.flagEmoji)
        }
    }
}
