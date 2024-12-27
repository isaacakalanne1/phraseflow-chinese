//
//  DifficultyView.swift
//  FlowTale
//
//  Created by iakalann on 27/12/2024.
//

import SwiftUI

struct DifficultyView: View {
    let difficulty: Difficulty
    private let starSize: CGFloat = 10

    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 2) {
                SystemImageView(difficulty.index >= 0 ? .starFilled : .star,
                                size: starSize)
                SystemImageView(difficulty.index >= 1 ? .starFilled : .star,
                                size: starSize)
            }
            HStack(spacing: 2) {
                SystemImageView(difficulty.index >= 2 ? .starFilled : .star,
                                size: starSize)
                SystemImageView(difficulty.index >= 3 ? .starFilled : .star,
                                size: starSize)
            }
        }
    }
}
