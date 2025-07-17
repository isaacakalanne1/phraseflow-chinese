//
//  BackgroundImageType.swift
//  FlowTale
//
//  Created by iakalann on 18/04/2025.
//

enum BackgroundImageType {
    case main, createStory

    var name: String {
        switch self {
        case .main:
            "Background"
        case .createStory:
            "CreateStoryBackground"
        }
    }
}
