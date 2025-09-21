//
//  MockStoryEnvironment.swift
//  Story
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Audio
import AudioMocks
import Combine
import Settings
import Story
import Study
import StudyMocks
import TextPractice
import TextPracticeMocks
import TextGeneration
import TextGenerationMocks
import UserLimit
import UserLimitMocks

enum MockStoryEnvironmentError: Error {
    case genericError
}

public class MockStoryEnvironment: StoryEnvironmentProtocol {
    var audioEnvironment: AudioEnvironmentProtocol
    var studyEnvironment: StudyEnvironmentProtocol
    public var textPracticeEnvironment: TextPracticeEnvironmentProtocol
    var userLimitEnvironment: UserLimitEnvironmentProtocol
    
    public var settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never>
    public var limitReachedSubject: CurrentValueSubject<LimitReachedEvent, Never>
    public var goToNextChapterSubject: CurrentValueSubject<Void?, Never>
    
    public init(
        audioEnvironment: AudioEnvironmentProtocol = MockAudioEnvironment(),
        studyEnvironment: StudyEnvironmentProtocol = MockStudyEnvironment(),
        textPracticeEnvironment: TextPracticeEnvironmentProtocol = MockTextPracticeEnvironment(),
        userLimitEnvironment: UserLimitEnvironmentProtocol = MockUserLimitEnvironment(),
        settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never> = .init(nil),
        limitReachedSubject: CurrentValueSubject<LimitReachedEvent, Never> = .init(.freeLimit),
        goToNextChapterSubject: CurrentValueSubject<Void?, Never> = .init(nil)
    ) {
        self.audioEnvironment = audioEnvironment
        self.studyEnvironment = studyEnvironment
        self.textPracticeEnvironment = textPracticeEnvironment
        self.userLimitEnvironment = userLimitEnvironment
        self.settingsUpdatedSubject = settingsUpdatedSubject
        self.limitReachedSubject = limitReachedSubject
        self.goToNextChapterSubject = goToNextChapterSubject
    }
    
    var loadAllChaptersCalled = false
    var loadAllChaptersResult: Result<[Chapter], MockStoryEnvironmentError> = .success([.arrange])
    public func loadAllChapters() throws -> [Chapter] {
        loadAllChaptersCalled = true
        switch loadAllChaptersResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var saveChapterSpy: Chapter?
    var saveChapterCalled = false
    var saveChapterResult: Result<Void, MockStoryEnvironmentError> = .success(())
    public func saveChapter(_ chapter: Chapter) throws {
        saveChapterSpy = chapter
        saveChapterCalled = true
        switch saveChapterResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var deleteChapterSpy: Chapter?
    var deleteChapterCalled = false
    var deleteChapterResult: Result<Void, MockStoryEnvironmentError> = .success(())
    public func deleteChapter(_ chapter: Chapter) throws {
        deleteChapterSpy = chapter
        deleteChapterCalled = true
        switch deleteChapterResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var saveAppSettingsSpy: SettingsState?
    var saveAppSettingsCalled = false
    var saveAppSettingsResult: Result<Void, MockStoryEnvironmentError> = .success(())
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
    
    var limitReachedSpy: LimitReachedEvent?
    var limitReachedCalled = false
    public func limitReached(_ event: LimitReachedEvent) {
        limitReachedSpy = event
        limitReachedCalled = true
    }
    
    var generateTextForChapterPreviousChaptersSpy: [Chapter]?
    var generateTextForChapterLanguageSpy: Language?
    var generateTextForChapterDifficultySpy: Difficulty?
    var generateTextForChapterVoiceSpy: Voice?
    var generateTextForChapterDeviceLanguageSpy: Language?
    var generateTextForChapterStoryPromptSpy: String?
    var generateTextForChapterCalled = false
    var generateTextForChapterResult: Result<Chapter, MockStoryEnvironmentError> = .success(.arrange)
    public func generateTextForChapter(
        previousChapters: [Chapter],
        language: Language?,
        difficulty: Difficulty?,
        voice: Voice?,
        deviceLanguage: Language?,
        storyPrompt: String?
    ) async throws -> Chapter {
        generateTextForChapterPreviousChaptersSpy = previousChapters
        generateTextForChapterLanguageSpy = language
        generateTextForChapterDifficultySpy = difficulty
        generateTextForChapterVoiceSpy = voice
        generateTextForChapterDeviceLanguageSpy = deviceLanguage
        generateTextForChapterStoryPromptSpy = storyPrompt
        
        generateTextForChapterCalled = true
        switch generateTextForChapterResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var generateChapterStoryPreviousChaptersSpy: [Chapter]?
    var generateChapterStoryLanguageSpy: Language?
    var generateChapterStoryDifficultySpy: Difficulty?
    var generateChapterStoryVoiceSpy: Voice?
    var generateChapterStoryStoryPromptSpy: String?
    var generateChapterStoryCalled = false
    var generateChapterStoryResult: Result<Chapter, MockStoryEnvironmentError> = .success(.arrange)
    public func generateChapterStory(
        previousChapters: [Chapter],
        language: Language?,
        difficulty: Difficulty?,
        voice: Voice?,
        storyPrompt: String?
    ) async throws -> Chapter {
        generateChapterStoryPreviousChaptersSpy = previousChapters
        generateChapterStoryLanguageSpy = language
        generateChapterStoryDifficultySpy = difficulty
        generateChapterStoryVoiceSpy = voice
        generateChapterStoryStoryPromptSpy = storyPrompt
        generateChapterStoryCalled = true
        
        switch generateChapterStoryResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var formatStoryIntoSentencesChapterSpy: Chapter?
    var formatStoryIntoSentencesDeviceLanguageSpy: Language?
    var formatStoryIntoSentencesCalled = false
    var formatStoryIntoSentencesResult: Result<Chapter, MockStoryEnvironmentError> = .success(.arrange)
    public func formatStoryIntoSentences(
        chapter: Chapter,
        deviceLanguage: Language?
    ) async throws -> Chapter {
        formatStoryIntoSentencesChapterSpy = chapter
        formatStoryIntoSentencesDeviceLanguageSpy = deviceLanguage
        formatStoryIntoSentencesCalled = true
        
        switch formatStoryIntoSentencesResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var generateImageForChapterChapterSpy: Chapter?
    var generateImageForChapterPreviousChaptersSpy: [Chapter]?
    var generateImageForChapterCalled = false
    var generateImageForChapterResult: Result<Chapter, MockStoryEnvironmentError> = .success(.arrange)
    public func generateImageForChapter(
        _ chapter: Chapter,
        previousChapters: [Chapter]
    ) async throws -> Chapter {
        generateImageForChapterChapterSpy = chapter
        generateImageForChapterPreviousChaptersSpy = previousChapters
        
        generateImageForChapterCalled = true
        switch generateImageForChapterResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var generateSpeechForChapterSpy: Chapter?
    var generateSpeechForChapterCalled = false
    var generateSpeechForChapterResult: Result<Chapter, MockStoryEnvironmentError> = .success(.arrange)
    public func generateSpeechForChapter(
        _ chapter: Chapter
    ) async throws -> Chapter {
        generateSpeechForChapterSpy = chapter
        generateSpeechForChapterCalled = true
        switch generateSpeechForChapterResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var generateDefinitionsForChapterChapterSpy: Chapter?
    var generateDefinitionsForChapterDeviceLanguageSpy: Language?
    var generateDefinitionsForChapterCalled = false
    var generateDefinitionsForChapterResult: Result<Chapter, MockStoryEnvironmentError> = .success(.arrange)
    public func generateDefinitionsForChapter(
        _ chapter: Chapter,
        deviceLanguage: Language?
    ) async throws -> Chapter {
        generateDefinitionsForChapterChapterSpy = chapter
        generateDefinitionsForChapterDeviceLanguageSpy = deviceLanguage
        generateDefinitionsForChapterCalled = true
        switch generateDefinitionsForChapterResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }

    var playSoundSpy: AppSound?
    var playSoundCalled = false
    public func playSound(_ sound: AppSound) {
        playSoundSpy = sound
        playSoundCalled = true
    }
    
    var cleanupDefinitionsNotInChaptersSpy: [Chapter]?
    var cleanupDefinitionsNotInChaptersCalled = false
    var cleanupDefinitionsNotInChaptersResult: Result<Void, MockStoryEnvironmentError> = .success(())
    public func cleanupDefinitionsNotInChapters(_ chapters: [Chapter]) throws {
        cleanupDefinitionsNotInChaptersSpy = chapters
        cleanupDefinitionsNotInChaptersCalled = true
        switch cleanupDefinitionsNotInChaptersResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var cleanupOrphanedSentenceAudioFilesCalled = false
    var cleanupOrphanedSentenceAudioFilesResult: Result<Void, MockStoryEnvironmentError> = .success(())
    public func cleanupOrphanedSentenceAudioFiles() throws {
        cleanupOrphanedSentenceAudioFilesCalled = true
        switch cleanupOrphanedSentenceAudioFilesResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
}
