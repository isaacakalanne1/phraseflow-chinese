//
//  StoryInfoView.swift
//  FlowTale
//
//  Created by iakalann on 26/12/2024.
//

import SwiftUI

struct StoryInfoView: View {
    let story: Story

    var body: some View {
        HStack {
            DifficultyView(difficulty: story.difficulty)
            Text(story.language.flagEmoji)
        }
    }
}
