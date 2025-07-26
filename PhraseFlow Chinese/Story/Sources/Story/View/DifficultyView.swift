//
//  DifficultyView.swift
//  FlowTale
//
//  Created by iakalann on 27/12/2024.
//

import SwiftUI
import TextGeneration
import Settings

struct DifficultyView: View {
    let difficulty: Difficulty
    let isSelected: Bool
    private let starSize: CGFloat = 10

    init(difficulty: Difficulty,
         isSelected: Bool = false)
    {
        self.difficulty = difficulty
        self.isSelected = isSelected
    }

    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 2) {
                SystemImageView(difficulty.index >= 0 ? .starFilled : .star,
                                size: starSize,
                                isSelected: isSelected)
                SystemImageView(difficulty.index >= 1 ? .starFilled : .star,
                                size: starSize,
                                isSelected: isSelected)
            }
            HStack(spacing: 2) {
                SystemImageView(difficulty.index >= 2 ? .starFilled : .star,
                                size: starSize,
                                isSelected: isSelected)
                SystemImageView(difficulty.index >= 3 ? .starFilled : .star,
                                size: starSize,
                                isSelected: isSelected)
            }
        }
    }
}
