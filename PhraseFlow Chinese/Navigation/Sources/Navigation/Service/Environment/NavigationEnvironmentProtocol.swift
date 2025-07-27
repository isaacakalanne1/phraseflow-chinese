//
//  NavigationEnvironmentProtocol.swift
//  Navigation
//
//  Created by iakalann on 17/07/2025.
//

import Foundation
import Audio
import Story

public protocol NavigationEnvironmentProtocol {
    var storyEnvironment: StoryEnvironmentProtocol { get }
    var audioEnvironment: AudioEnvironmentProtocol { get }
    @MainActor func selectChapter(storyId: UUID)
    func playSound(_ sound: AppSound)
}
