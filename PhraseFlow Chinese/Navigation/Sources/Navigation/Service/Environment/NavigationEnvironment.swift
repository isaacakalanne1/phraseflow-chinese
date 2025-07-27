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
    public let settingsEnvironment: SettingsEnvironmentProtocol
    public let storyEnvironment: StoryEnvironmentProtocol
    public let audioEnvironment: AudioEnvironmentProtocol
    
    public init(
        settingsEnvironment: SettingsEnvironmentProtocol,
        storyEnvironment: StoryEnvironmentProtocol,
        audioEnvironment: AudioEnvironmentProtocol
    ) {
        self.settingsEnvironment = settingsEnvironment
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
