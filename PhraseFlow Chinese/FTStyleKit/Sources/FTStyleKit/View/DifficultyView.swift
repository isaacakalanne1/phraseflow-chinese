//
//  DifficultyView.swift
//  FlowTale
//
//  Created by iakalann on 27/12/2024.
//

import SwiftUI
import AppleIcon

public struct DifficultyView: View {
    let difficultyIndex: Int
    private let starSize: CGFloat = 10

    public init(difficultyIndex: Int) {
        self.difficultyIndex = difficultyIndex
    }

    public var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 2) {
                SystemImageView(difficultyIndex >= 0 ? .starFilled : .star,
                                size: starSize,
                                isSelected: true)
                SystemImageView(difficultyIndex >= 1 ? .starFilled : .star,
                                size: starSize,
                                isSelected: true)
            }
            HStack(spacing: 2) {
                SystemImageView(difficultyIndex >= 2 ? .starFilled : .star,
                                size: starSize,
                                isSelected: true)
                SystemImageView(difficultyIndex >= 3 ? .starFilled : .star,
                                size: starSize,
                                isSelected: true)
            }
        }
    }
}
