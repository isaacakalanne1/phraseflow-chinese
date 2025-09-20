//
//  CreateChapterType.swift
//  FlowTale
//
//  Created by iakalann on 17/04/2025.
//

import Foundation

public enum CreateChapterType: Sendable, Equatable {
    case newStory
    case existingStory(UUID)
}
