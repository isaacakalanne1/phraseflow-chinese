//
//  NavigationEnvironment.swift
//  Navigation
//
//  Created by iakalann on 17/07/2025.
//

import Foundation
import Story

struct NavigationEnvironment: NavigationEnvironmentProtocol {
    let storyEnvironment: StoryEnvironmentProtocol
    
    init(storyEnvironment: StoryEnvironmentProtocol) {
        self.storyEnvironment = storyEnvironment
    }
    
    func selectChapter(storyId: UUID) {
        storyEnvironment.selectChapter(storyId: storyId)
    }
}
