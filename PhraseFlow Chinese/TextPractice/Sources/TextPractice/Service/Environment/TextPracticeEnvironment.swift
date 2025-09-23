//
//  TextPracticeEnvironment.swift
//  TextPractice
//
//  Created by Isaac Akalanne on 02/09/2025.
//

import Foundation
import Audio
import Combine
import TextGeneration
import Settings
import Study

public struct TextPracticeEnvironment: TextPracticeEnvironmentProtocol {
    public var chapterSubject: CurrentValueSubject<Chapter?, Never>
    public var definitionsSubject: CurrentValueSubject<[Definition]?, Never> {
        studyEnvironment.definitionsSubject
    }
    public var goToNextChapterSubject: CurrentValueSubject<Void?, Never>
    public var settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never> {
        settingsEnvironment.settingsUpdatedSubject
    }
    public var chapterAudioDataSubject: CurrentValueSubject<Data?, Never>
    
    public let audioEnvironment: AudioEnvironmentProtocol
    private let settingsEnvironment: SettingsEnvironmentProtocol
    public let studyEnvironment: StudyEnvironmentProtocol
    
    public init(
        audioEnvironment: AudioEnvironmentProtocol,
        settingsEnvironment: SettingsEnvironmentProtocol,
        studyEnvironment: StudyEnvironmentProtocol
    ) {
        self.audioEnvironment = audioEnvironment
        self.settingsEnvironment = settingsEnvironment
        self.studyEnvironment = studyEnvironment
        
        chapterSubject = .init(nil)
        goToNextChapterSubject = .init(nil)
        chapterAudioDataSubject = .init(nil)
    }
    
    public func saveAppSettings(_ settings: SettingsState) throws {
        try settingsEnvironment.saveAppSettings(settings)
    }
    
    public func saveDefinitions(_ definitions: [Definition]) throws {
        try studyEnvironment.saveDefinitions(definitions)
    }
    
    public func addDefinitions(_ definitions: [Definition]) {
        studyEnvironment.definitionsSubject.send(definitions)
    }
    
    public func goToNextChapter() {
        goToNextChapterSubject.send(())
    }
    
    public func prepareToPlayChapter(_ chapter: Chapter) async {
        chapterAudioDataSubject.send(chapter.audio.data)
    }
    
    public func setMusicVolume(_ volume: MusicVolume) {
        audioEnvironment.setMusicVolume(volume)
    }
    
    public func playSound(_ sound: AppSound) {
        audioEnvironment.playSound(sound)
    }
    
    public func saveSentenceAudio(_ audio: Data, id: UUID) throws {
        try studyEnvironment.saveSentenceAudio(audio, id: id)
    }
}
