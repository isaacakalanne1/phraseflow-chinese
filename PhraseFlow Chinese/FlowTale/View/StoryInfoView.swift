//
//  StoryInfoView.swift
//  FlowTale
//
//  Created by iakalann on 26/12/2024.
//

import SwiftUI

struct StoryInfoView: View {
    let story: Story
    private let starSize: CGFloat = 10

    var body: some View {
        HStack {
            Text(story.language.flagEmoji)
            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    SystemImageView(story.difficulty.index >= 0 ? .starFilled : .star,
                                    size: starSize)
                    SystemImageView(story.difficulty.index >= 1 ? .starFilled : .star,
                                    size: starSize)
                }
                HStack(spacing: 2) {
                    SystemImageView(story.difficulty.index >= 2 ? .starFilled : .star,
                                    size: starSize)
                    SystemImageView(story.difficulty.index >= 3 ? .starFilled : .star,
                                    size: starSize)
                }
            }
        }
    }
}
