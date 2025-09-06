//
//  TextPracticeEnvironmentProtocol.swift
//  TextPractice
//
//  Created by Isaac Akalanne on 02/09/2025.
//

import Audio
import Combine
import TextGeneration
import Settings
import Study

public protocol TextPracticeEnvironmentProtocol {
    var chapterSubject: CurrentValueSubject<Chapter?, Never> { get }
    var definitionsSubject: CurrentValueSubject<[Definition]?, Never> { get }
    var goToNextChapterSubject: CurrentValueSubject<Void?, Never> { get }
    var settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never> { get }
    
    var audioEnvironment: AudioEnvironmentProtocol { get }
    
    func getAppSettings() throws -> SettingsState
    func saveAppSettings(_ settings: SettingsState) throws
    
    func setChapter(_ chapter: Chapter?)
    func addDefinitions(_ definitions: [Definition])
    func goToNextChapter()
    
    func prepareToPlayChapter(_ chapter: Chapter) async
    func playWord(
        _ word: WordTimeStampData,
        rate: Float
    ) async
    func playChapter(from word: WordTimeStampData,
                     speechSpeed: SpeechSpeed) async
    func pauseChapter()
    func setMusicVolume(_ volume: MusicVolume)
    func playSound(_ sound: AppSound)
}
