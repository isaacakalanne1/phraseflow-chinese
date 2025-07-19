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

struct NavigationEnvironment: NavigationEnvironmentProtocol {
    let storyEnvironment: StoryEnvironmentProtocol
    let audioEnvironment: AudioEnvironmentProtocol
    
    init(storyEnvironment: StoryEnvironmentProtocol, audioEnvironment: AudioEnvironmentProtocol) {
        self.storyEnvironment = storyEnvironment
        self.audioEnvironment = audioEnvironment
    }
    
    init() {
        self.storyEnvironment = StoryEnvironment()
        let settingsDataStore = SettingsDataStore()
        let settingsEnvironment = SettingsEnvironment(settingsDataStore: settingsDataStore)
        self.audioEnvironment = AudioEnvironment(settingsEnvironment: settingsEnvironment)
    }
    
    func selectChapter(storyId: UUID) {
        storyEnvironment.selectChapter(storyId: storyId)
    }
    
    func playSound(_ sound: AppSound) {
        audioEnvironment.playSound(sound)
    }
}
