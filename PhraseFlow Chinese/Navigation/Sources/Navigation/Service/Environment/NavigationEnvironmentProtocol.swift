//
//  NavigationEnvironmentProtocol.swift
//  Navigation
//
//  Created by iakalann on 17/07/2025.
//

import Foundation
import Audio
import Settings
import Story

public protocol NavigationEnvironmentProtocol {
    var settingsEnvironment: SettingsEnvironmentProtocol { get }
    var storyEnvironment: StoryEnvironmentProtocol { get }
    var audioEnvironment: AudioEnvironmentProtocol { get }
    @MainActor func selectChapter(storyId: UUID)
    func playSound(_ sound: AppSound)
}
