//
//  TextPracticeEnvironmentTests.swift
//  TextPractice
//
//  Created by Isaac Akalanne on 21/09/2025.
//

import Foundation
import Testing
import Combine
import Audio
@testable import AudioMocks
import Settings
@testable import SettingsMocks
import Study
@testable import StudyMocks
import TextGeneration
import TextGenerationMocks
@testable import TextPractice
@testable import TextPracticeMocks

class TextPracticeEnvironmentTests {
    let environment: TextPracticeEnvironmentProtocol
    let mockAudioEnvironment: MockAudioEnvironment
    let mockSettingsEnvironment: MockSettingsEnvironment
    let mockStudyEnvironment: MockStudyEnvironment
    
    init() {
        self.mockAudioEnvironment = MockAudioEnvironment()
        self.mockSettingsEnvironment = MockSettingsEnvironment()
        self.mockStudyEnvironment = MockStudyEnvironment()
        
        self.environment = TextPracticeEnvironment(
            audioEnvironment: mockAudioEnvironment,
            settingsEnvironment: mockSettingsEnvironment,
            studyEnvironment: mockStudyEnvironment
        )
    }
    
    @Test
    func saveAppSettings_success() throws {
        let expectedSettings = SettingsState.arrange
        mockSettingsEnvironment.saveAppSettingsResult = .success(())
        
        try environment.saveAppSettings(expectedSettings)
        
        #expect(mockSettingsEnvironment.saveAppSettingsSpy == expectedSettings)
        #expect(mockSettingsEnvironment.saveAppSettingsCalled == true)
    }
    
    @Test
    func saveAppSettings_error() throws {
        let expectedSettings = SettingsState.arrange
        mockSettingsEnvironment.saveAppSettingsResult = .failure(.genericError)
        
        do {
            try environment.saveAppSettings(expectedSettings)
            Issue.record("Should have thrown an error")
        } catch {
            #expect(mockSettingsEnvironment.saveAppSettingsSpy == expectedSettings)
            #expect(mockSettingsEnvironment.saveAppSettingsCalled == true)
        }
    }
    
    @Test
    func saveDefinitions_success() throws {
        let expectedDefinitions = [Definition.arrange]
        mockStudyEnvironment.saveDefinitionsResult = .success(())
        
        try environment.saveDefinitions(expectedDefinitions)
        
        #expect(mockStudyEnvironment.saveDefinitionsSpy == expectedDefinitions)
        #expect(mockStudyEnvironment.saveDefinitionsCalled == true)
    }
    
    @Test
    func saveDefinitions_error() throws {
        let expectedDefinitions = [Definition.arrange]
        mockStudyEnvironment.saveDefinitionsResult = .failure(.genericError)
        
        do {
            try environment.saveDefinitions(expectedDefinitions)
            Issue.record("Should have thrown an error")
        } catch {
            #expect(mockStudyEnvironment.saveDefinitionsSpy == expectedDefinitions)
            #expect(mockStudyEnvironment.saveDefinitionsCalled == true)
        }
    }
    
    @Test
    func addDefinitions_sendsToSubject() {
        let expectedDefinitions = [Definition.arrange]
        
        environment.addDefinitions(expectedDefinitions)
        
        #expect(mockStudyEnvironment.definitionsSubject.value == expectedDefinitions)
    }
    
    @Test
    func goToNextChapter_sendsToSubject() {
        environment.goToNextChapter()
        
        #expect(environment.goToNextChapterSubject.value != nil)
    }
    
    @Test
    func prepareToPlayChapter() async {
        let chapterData = Data("test audio data".utf8)
        let chapter = Chapter.arrange(audio: .arrange(data: chapterData))
        
        await environment.prepareToPlayChapter(chapter)
        
        #expect(mockAudioEnvironment.setChapterAudioDataSpy == chapterData)
        #expect(mockAudioEnvironment.setChapterAudioDataCalled == true)
    }
    
    @Test
    func playWord() async {
        let word = WordTimeStampData.arrange(time: 10.5, duration: 1.5)
        let rate: Float = 1.5
        
        await environment.playWord(word, rate: rate)
        
        #expect(mockAudioEnvironment.playWordStartTimeSpy == word.time)
        #expect(mockAudioEnvironment.playWordDurationSpy == word.duration)
        #expect(mockAudioEnvironment.playWordPlayRateSpy == rate)
        #expect(mockAudioEnvironment.playWordCalled == true)
    }
    
    @Test
    func playChapter() async {
        let word = WordTimeStampData.arrange(time: 20.0)
        let speechSpeed = SpeechSpeed.fast
        
        await environment.playChapter(from: word, speechSpeed: speechSpeed)
        
        #expect(mockAudioEnvironment.playChapterAudioFromTimeSpy == word.time)
        #expect(mockAudioEnvironment.playChapterAudioRateSpy == speechSpeed.playRate)
        #expect(mockAudioEnvironment.playChapterAudioCalled == true)
    }
    
    @Test
    func pauseChapter() {
        environment.pauseChapter()
        
        #expect(mockAudioEnvironment.pauseChapterAudioCalled == true)
    }
    
    @Test
    func setMusicVolume() {
        let volume = MusicVolume.quiet
        
        environment.setMusicVolume(volume)
        
        #expect(mockAudioEnvironment.setMusicVolumeSpy == volume)
        #expect(mockAudioEnvironment.setMusicVolumeCalled == true)
    }
    
    @Test
    func playSound() {
        let sound = AppSound.actionButtonPress
        
        environment.playSound(sound)
        
        #expect(mockAudioEnvironment.playSoundSpy == sound)
        #expect(mockAudioEnvironment.playSoundCalled == true)
    }
    
    @Test
    func saveSentenceAudio_success() throws {
        let audioData = Data("sentence audio".utf8)
        let sentenceId = UUID()
        mockStudyEnvironment.saveSentenceAudioResult = .success(())
        
        try environment.saveSentenceAudio(audioData, id: sentenceId)
        
        #expect(mockStudyEnvironment.saveSentenceAudioAudioDataSpy == audioData)
        #expect(mockStudyEnvironment.saveSentenceAudioIdSpy == sentenceId)
        #expect(mockStudyEnvironment.saveSentenceAudioCalled == true)
    }
    
    @Test
    func saveSentenceAudio_error() throws {
        let audioData = Data("sentence audio".utf8)
        let sentenceId = UUID()
        mockStudyEnvironment.saveSentenceAudioResult = .failure(.genericError)
        
        do {
            try environment.saveSentenceAudio(audioData, id: sentenceId)
            Issue.record("Should have thrown an error")
        } catch {
            #expect(mockStudyEnvironment.saveSentenceAudioAudioDataSpy == audioData)
            #expect(mockStudyEnvironment.saveSentenceAudioIdSpy == sentenceId)
            #expect(mockStudyEnvironment.saveSentenceAudioCalled == true)
        }
    }
    
    @Test
    func definitionsSubject_returnsStudyEnvironmentSubject() {
        let expectedDefinitions = [Definition.arrange]
        mockStudyEnvironment.definitionsSubject.send(expectedDefinitions)
        
        #expect(environment.definitionsSubject.value == expectedDefinitions)
    }
    
    @Test
    func settingsUpdatedSubject_returnsSettingsEnvironmentSubject() {
        let expectedSettings = SettingsState.arrange
        mockSettingsEnvironment.settingsUpdatedSubject.send(expectedSettings)
        
        #expect(environment.settingsUpdatedSubject.value == expectedSettings)
    }
}
