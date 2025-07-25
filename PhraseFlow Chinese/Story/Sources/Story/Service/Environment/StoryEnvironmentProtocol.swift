//
//  StoryEnvironmentProtocol.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Audio
import Foundation
import Combine
import Settings

public protocol StoryEnvironmentProtocol {
    var storySubject: CurrentValueSubject<UUID?, Never> { get }
    func selectChapter(storyId: UUID)
    func playWord(_ word: WordTimeStampData, rate: Float)
    func getAppSettings() throws -> SettingsState
    func playChapter(from word: WordTimeStampData)
    func pauseChapter()
    func setMusicVolume(_ volume: MusicVolume)
}
