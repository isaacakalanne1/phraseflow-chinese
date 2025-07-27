//
//  NavigationEnvironment.swift
//  Navigation
//
//  Created by iakalann on 17/07/2025.
//

import Foundation
import Story
import Audio
import Settings
import DataStorage

public struct NavigationEnvironment: NavigationEnvironmentProtocol {
    let storyEnvironment: StoryEnvironmentProtocol
    let audioEnvironment: AudioEnvironmentProtocol
    
    public init(storyEnvironment: StoryEnvironmentProtocol, audioEnvironment: AudioEnvironmentProtocol) {
        self.storyEnvironment = storyEnvironment
        self.audioEnvironment = audioEnvironment
    }
    
    
    @MainActor
    public func selectChapter(storyId: UUID) {
        storyEnvironment.selectChapter(storyId: storyId)
    }
    
    public func playSound(_ sound: AppSound) {
        audioEnvironment.playSound(sound)
    }
}
