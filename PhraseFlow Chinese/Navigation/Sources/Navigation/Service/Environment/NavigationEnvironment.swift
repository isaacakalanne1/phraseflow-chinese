//
//  NavigationEnvironment.swift
//  Navigation
//
//  Created by iakalann on 17/07/2025.
//

import Foundation
import Story
import Audio

struct NavigationEnvironment: NavigationEnvironmentProtocol {
    let storyEnvironment: StoryEnvironmentProtocol
    let audioEnvironment: AudioEnvironmentProtocol
    
    init(storyEnvironment: StoryEnvironmentProtocol, audioEnvironment: AudioEnvironmentProtocol) {
        self.storyEnvironment = storyEnvironment
        self.audioEnvironment = audioEnvironment
    }
    
    func selectChapter(storyId: UUID) {
        storyEnvironment.selectChapter(storyId: storyId)
    }
    
    func playSound(_ sound: AppSound) {
        audioEnvironment.playSound(sound)
    }
}
