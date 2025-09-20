//
//  MockTextPracticeEnvironment.swift
//  TextPractice
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Audio
import AudioMocks
import Combine
import Foundation
import Settings
import Study
import StudyMocks
import TextGeneration
import TextPractice

enum MockTextPracticeEnvironmentError: Error {
    case genericError
}

public class MockTextPracticeEnvironment: TextPracticeEnvironmentProtocol {
    
    public var definitionsSubject: CurrentValueSubject<[Definition]?, Never>
    public var goToNextChapterSubject: CurrentValueSubject<Void?, Never>
    public var settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never>
    
    public var audioEnvironment: AudioEnvironmentProtocol
    public var studyEnvironment: StudyEnvironmentProtocol
    
    public init(
        definitionsSubject: CurrentValueSubject<[Definition]?, Never> = .init(nil),
        goToNextChapterSubject: CurrentValueSubject<Void?, Never> = .init(nil),
        settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never> = .init(nil),
        audioEnvironment: AudioEnvironmentProtocol = MockAudioEnvironment(),
        studyEnvironment: StudyEnvironmentProtocol = MockStudyEnvironment()
    ) {
        self.definitionsSubject = definitionsSubject
        self.goToNextChapterSubject = goToNextChapterSubject
        self.settingsUpdatedSubject = settingsUpdatedSubject
        self.audioEnvironment = audioEnvironment
        self.studyEnvironment = studyEnvironment
    }
    
    var saveAppSettingsSpy: SettingsState?
    var saveAppSettingsCalled = false
    var saveAppSettingsResult: Result<Void, MockTextPracticeEnvironmentError> = .success(())
    public func saveAppSettings(_ settings: SettingsState) throws {
        saveAppSettingsSpy = settings
        saveAppSettingsCalled = true
        switch saveAppSettingsResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var saveDefinitionsSpy: [Definition]?
    var saveDefinitionsCalled = false
    var saveDefinitionsResult: Result<Void, MockTextPracticeEnvironmentError> = .success(())
    public func saveDefinitions(_ definitions: [Definition]) throws {
        saveDefinitionsSpy = definitions
        saveDefinitionsCalled = true
        switch saveDefinitionsResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var addDefinitionsSpy: [Definition]?
    var addDefinitionsCalled = false
    public func addDefinitions(_ definitions: [Definition]) {
        addDefinitionsSpy = definitions
        addDefinitionsCalled = true
    }
    
    var goToNextChapterCalled = false
    public func goToNextChapter() {
        goToNextChapterCalled = true
        goToNextChapterSubject.send(())
    }
    
    var prepareToPlayChapterSpy: Chapter?
    var prepareToPlayChapterCalled = false
    public func prepareToPlayChapter(_ chapter: Chapter) async {
        prepareToPlayChapterSpy = chapter
        prepareToPlayChapterCalled = true
    }
    
    var playWordWordSpy: WordTimeStampData?
    var playWordRateSpy: Float?
    var playWordCalled = false
    public func playWord(
        _ word: WordTimeStampData,
        rate: Float
    ) async {
        playWordWordSpy = word
        playWordRateSpy = rate
        playWordCalled = true
    }
    
    var playChapterFromWordSpy: WordTimeStampData?
    var playChapterSpeechSpeedSpy: SpeechSpeed?
    var playChapterCalled = false
    public func playChapter(from word: WordTimeStampData,
                     speechSpeed: SpeechSpeed) async {
        playChapterFromWordSpy = word
        playChapterSpeechSpeedSpy = speechSpeed
        playChapterCalled = true
    }
    
    var pauseChapterCalled = false
    public func pauseChapter() {
        pauseChapterCalled = true
    }
    
    var setMusicVolumeSpy: MusicVolume?
    var setMusicVolumeCalled = false
    public func setMusicVolume(_ volume: MusicVolume) {
        setMusicVolumeSpy = volume
        setMusicVolumeCalled = true
    }
    
    var playSoundSpy: AppSound?
    var playSoundCalled = false
    public func playSound(_ sound: AppSound) {
        playSoundSpy = sound
        playSoundCalled = true
    }
    
    var saveSentenceAudioAudioSpy: Data?
    var saveSentenceAudioIdSpy: UUID?
    var saveSentenceAudioCalled = false
    var saveSentenceAudioResult: Result<Void, MockTextPracticeEnvironmentError> = .success(())
    public func saveSentenceAudio(_ audio: Data, id: UUID) throws {
        saveSentenceAudioAudioSpy = audio
        saveSentenceAudioIdSpy = id
        saveSentenceAudioCalled = true
        switch saveSentenceAudioResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
}