//
//  StoryEnvironmentTests.swift
//  Story
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Testing
import Foundation
import Combine
import Settings
import TextGeneration
import Study
import ImageGeneration
@testable import ImageGenerationMocks
import Speech
@testable import SpeechMocks
import Audio
import Loading
@testable import LoadingMocks
import TextPractice
import UserLimit
@testable import Story
@testable import StoryMocks
@testable import AudioMocks
@testable import StudyMocks
@testable import SettingsMocks
@testable import TextGenerationMocks
@testable import TextPracticeMocks
@testable import UserLimitMocks

final class StoryEnvironmentTests {
    
    let mockAudioEnvironment: MockAudioEnvironment
    let mockSettingsEnvironment: MockSettingsEnvironment
    let mockStudyEnvironment: MockStudyEnvironment
    let mockTextPracticeEnvironment: MockTextPracticeEnvironment
    let mockUserLimitEnvironment: MockUserLimitEnvironment
    let mockTextGenerationService: MockTextGenerationServices
    let mockImageGenerationService: MockImageGenerationServices
    let mockStoryDataStore: MockStoryDataStore
    let mockSpeechEnvironment: MockSpeechEnvironment
    let mockLoadingEnvironment: MockLoadingEnvironment
    
    var storyEnvironment: StoryEnvironment
    
    init() {
        mockAudioEnvironment = MockAudioEnvironment()
        mockSettingsEnvironment = MockSettingsEnvironment()
        mockStudyEnvironment = MockStudyEnvironment()
        mockTextPracticeEnvironment = MockTextPracticeEnvironment()
        mockUserLimitEnvironment = MockUserLimitEnvironment()
        mockTextGenerationService = MockTextGenerationServices()
        mockImageGenerationService = MockImageGenerationServices()
        mockStoryDataStore = MockStoryDataStore()
        mockSpeechEnvironment = MockSpeechEnvironment()
        mockLoadingEnvironment = MockLoadingEnvironment()
        
        storyEnvironment = StoryEnvironment(
            audioEnvironment: mockAudioEnvironment,
            settingsEnvironment: mockSettingsEnvironment,
            speechEnvironment: mockSpeechEnvironment,
            studyEnvironment: mockStudyEnvironment,
            textPracticeEnvironment: mockTextPracticeEnvironment,
            loadingEnvironment: mockLoadingEnvironment,
            userLimitEnvironment: mockUserLimitEnvironment,
            textGenerationService: mockTextGenerationService,
            imageGenerationService: mockImageGenerationService,
            dataStore: mockStoryDataStore
        )
    }
    
    @Test
    func saveAppSettings_delegatesToSettingsEnvironment() async throws {
        let settings = SettingsState.arrange
        mockSettingsEnvironment.saveAppSettingsResult = .success(())
        
        try storyEnvironment.saveAppSettings(settings)
        
        #expect(mockSettingsEnvironment.saveAppSettingsCalled == true)
        #expect(mockSettingsEnvironment.saveAppSettingsSpy == settings)
    }
    
    @Test
    func saveAppSettings_whenError_throwsError() async throws {
        let settings = SettingsState.arrange
        mockSettingsEnvironment.saveAppSettingsResult = .failure(.genericError)
        
        var threwError = false
        do {
            try storyEnvironment.saveAppSettings(settings)
        } catch {
            threwError = true
        }
        
        #expect(threwError == true)
        #expect(mockSettingsEnvironment.saveAppSettingsCalled == true)
    }
    
    @Test
    func limitReached_sendsEventToSubject() {
        let event = LimitReachedEvent.freeLimit
        
        storyEnvironment.limitReached(event)
        
        #expect(storyEnvironment.limitReachedSubject.value == event)
    }
    
    @Test
    func generateTextForChapter_withEmptyPreviousChapters_generatesFirstChapter() async throws {
        let language = Language.spanish
        let difficulty = Difficulty.beginner
        let voice = Voice.elvira
        let deviceLanguage = Language.english
        let storyPrompt = "A story about dragons"
        let storyChapter = Chapter.arrange(passage: "Story text")
        let formattedChapter = Chapter.arrange(sentences: [.arrange])
        
        mockTextGenerationService.generateChapterStoryResult = .success(storyChapter)
        mockTextGenerationService.formatStoryIntoSentencesResult = .success(formattedChapter)
        
        let result = try await storyEnvironment.generateTextForChapter(
            previousChapters: [],
            language: language,
            difficulty: difficulty,
            voice: voice,
            deviceLanguage: deviceLanguage,
            storyPrompt: storyPrompt
        )
        
        #expect(result == formattedChapter)
        #expect(mockTextGenerationService.generateChapterStoryCalled == true)
        #expect(mockTextGenerationService.formatStoryIntoSentencesCalled == true)
        #expect(mockTextGenerationService.generateChapterStoryLanguageSpy == language)
        #expect(mockTextGenerationService.generateChapterStoryDifficultySpy == difficulty)
        #expect(mockTextGenerationService.generateChapterStoryVoiceSpy == voice)
        #expect(mockTextGenerationService.generateChapterStoryStoryPromptSpy == storyPrompt)
        #expect(mockLoadingEnvironment.updateLoadingStatusSpy == .formattingSentences)
    }
    
    @Test
    func generateTextForChapter_withPreviousChapters_generatesNextChapter() async throws {
        let previousChapters = [Chapter.arrange]
        let deviceLanguage = Language.english
        let storyChapter = Chapter.arrange(passage: "Story text")
        let formattedChapter = Chapter.arrange(sentences: [.arrange])
        
        mockTextGenerationService.generateChapterStoryResult = .success(storyChapter)
        mockTextGenerationService.formatStoryIntoSentencesResult = .success(formattedChapter)
        
        let result = try await storyEnvironment.generateTextForChapter(
            previousChapters: previousChapters,
            language: nil,
            difficulty: nil,
            voice: nil,
            deviceLanguage: deviceLanguage,
            storyPrompt: nil
        )
        
        #expect(result == formattedChapter)
        #expect(mockTextGenerationService.generateChapterStoryCalled == true)
        #expect(mockTextGenerationService.formatStoryIntoSentencesCalled == true)
        #expect(mockTextGenerationService.generateChapterStoryPreviousChaptersSpy == previousChapters)
    }
    
    @Test
    func generateTextForChapter_withEmptyPreviousChaptersAndMissingParameters_throwsError() async throws {
        mockTextGenerationService.generateChapterStoryResult = .failure(.genericError)
        
        do {
            _ = try await storyEnvironment.generateTextForChapter(
                previousChapters: [],
                language: nil,
                difficulty: nil,
                voice: nil,
                deviceLanguage: .english,
                storyPrompt: nil
            )
            Issue.record("Should have thrown error")
        } catch {
            #expect(mockLoadingEnvironment.updateLoadingStatusSpy == .writing)
        }
    }
    
    @Test
    func generateImageForChapter_withoutImageData_generatesNewImage() async throws {
        let chapter = Chapter.arrange(
            passage: "A beautiful story",
            imageData: nil
        )
        let expectedImageData = Data("generated image".utf8)
        
        mockImageGenerationService.generateImageResult = .success(expectedImageData)
        
        let result = try await storyEnvironment.generateImageForChapter(chapter)
        
        #expect(result.imageData == expectedImageData)
        #expect(mockImageGenerationService.generateImageCalled == true)
        #expect(mockImageGenerationService.generateImagePromptSpy == chapter.passage)
        #expect(mockLoadingEnvironment.updateLoadingStatusSpy == .generatingImage)
    }
    
    @Test
    func generateImageForChapter_withExistingImageData_keepsExistingImage() async throws {
        let existingImageData = Data("existing image".utf8)
        let chapter = Chapter.arrange(imageData: existingImageData)
        
        let result = try await storyEnvironment.generateImageForChapter(chapter)
        
        #expect(result.imageData == existingImageData)
        #expect(mockImageGenerationService.generateImageCalled == false)
    }
    
    @Test
    func generateImageForChapter_withFirstChapterHavingImage_reusesFirstChapterImage() async throws {
        let firstChapterImageData = Data("first chapter image".utf8)
        let firstChapter = Chapter.arrange(imageData: firstChapterImageData)
        let currentChapter = Chapter.arrange(
            passage: "Chapter 2",
            imageData: nil
        )
        
        let result = try await storyEnvironment.generateImageForChapter(
            currentChapter,
            previousChapters: [firstChapter]
        )
        
        #expect(result.imageData == firstChapterImageData)
        #expect(mockImageGenerationService.generateImageCalled == false)
    }
    
    @Test
    func generateImageForChapter_withEmptyPassage_doesNotGenerateImage() async throws {
        let chapter = Chapter.arrange(
            passage: "",
            imageData: nil
        )
        
        let result = try await storyEnvironment.generateImageForChapter(chapter)
        
        #expect(result.imageData == nil)
        #expect(mockImageGenerationService.generateImageCalled == false)
    }
    
    @Test
    func generateSpeechForChapter_delegatesToSpeechEnvironment() async throws {
        let chapter = Chapter.arrange
        let expectedChapter = Chapter.arrange(title: "With Speech")
        
        mockSpeechEnvironment.synthesizeSpeechResult = .success(expectedChapter)
        
        let result = try await storyEnvironment.generateSpeechForChapter(chapter)
        
        #expect(result == expectedChapter)
        #expect(mockSpeechEnvironment.synthesizeSpeechCalled == true)
        #expect(mockSpeechEnvironment.synthesizeSpeechChapterSpy == chapter)
        #expect(mockSpeechEnvironment.synthesizeSpeechVoiceSpy == chapter.audioVoice)
        #expect(mockSpeechEnvironment.synthesizeSpeechLanguageSpy == chapter.language)
        #expect(mockLoadingEnvironment.updateLoadingStatusSpy == .generatingSpeech)
    }
    
    @Test
    func generateDefinitionsForChapter_processesFirstThreeSentences() async throws {
        let sentence1 = Sentence.arrange
        let sentence2 = Sentence.arrange
        let sentence3 = Sentence.arrange
        let sentence4 = Sentence.arrange
        let chapter = Chapter.arrange(sentences: [sentence1, sentence2, sentence3, sentence4])
        let definitions = [Definition.arrange, Definition.arrange]
        
        mockStudyEnvironment.fetchDefinitionsResult = .success(definitions)
        mockStudyEnvironment.saveDefinitionsResult = .success(())
        
        let result = try await storyEnvironment.generateDefinitionsForChapter(
            chapter,
            deviceLanguage: .english
        )
        
        #expect(result == chapter)
        #expect(mockStudyEnvironment.fetchDefinitionsCalled == true)
        #expect(mockStudyEnvironment.saveDefinitionsCalled == true)
        #expect(mockLoadingEnvironment.updateLoadingStatusSpy == .complete)
    }
    
    @Test
    func generateDefinitionsForChapter_withNoDefinitions_doesNotSave() async throws {
        let chapter = Chapter.arrange
        
        mockStudyEnvironment.fetchDefinitionsResult = .success([])
        
        let result = try await storyEnvironment.generateDefinitionsForChapter(
            chapter,
            deviceLanguage: .english
        )
        
        #expect(result == chapter)
        #expect(mockStudyEnvironment.fetchDefinitionsCalled == true)
        #expect(mockStudyEnvironment.saveDefinitionsCalled == false)
    }
    
    @Test
    func saveChapter_withFirstChapter_savesWithImageData() throws {
        let chapter = Chapter.arrange(imageData: Data("image".utf8))
        
        mockStoryDataStore.loadAllChaptersForStoryIdResult = .success([])
        mockStoryDataStore.saveChapterResult = .success(())
        
        try storyEnvironment.saveChapter(chapter)
        
        #expect(mockStoryDataStore.saveChapterCalled == true)
        #expect(mockStoryDataStore.saveChapterSpy?.imageData != nil)
    }
    
    @Test
    func saveChapter_withSubsequentChapter_savesWithoutImageData() throws {
        let existingChapter = Chapter.arrange
        let newChapter = Chapter.arrange(imageData: Data("image".utf8))
        
        mockStoryDataStore.loadAllChaptersForStoryIdResult = .success([existingChapter])
        mockStoryDataStore.saveChapterResult = .success(())
        
        try storyEnvironment.saveChapter(newChapter)
        
        #expect(mockStoryDataStore.saveChapterCalled == true)
        #expect(mockStoryDataStore.saveChapterSpy?.imageData == nil)
    }
    
    @Test
    func loadAllChapters_delegatesToDataStore() throws {
        let expectedChapters = [Chapter.arrange, Chapter.arrange]
        mockStoryDataStore.loadAllChaptersResult = .success(expectedChapters)
        
        let result = try storyEnvironment.loadAllChapters()
        
        #expect(result == expectedChapters)
        #expect(mockStoryDataStore.loadAllChaptersCalled == true)
    }
    
    @Test
    func deleteChapter_delegatesToDataStore() throws {
        let chapter = Chapter.arrange
        mockStoryDataStore.deleteChapterResult = .success(())
        
        try storyEnvironment.deleteChapter(chapter)
        
        #expect(mockStoryDataStore.deleteChapterCalled == true)
        #expect(mockStoryDataStore.deleteChapterSpy == chapter)
    }
    
    @Test
    func playSound_delegatesToAudioEnvironment() {
        let sound = AppSound.actionButtonPress
        
        storyEnvironment.playSound(sound)
        
        #expect(mockAudioEnvironment.playSoundCalled == true)
        #expect(mockAudioEnvironment.playSoundSpy == sound)
    }
    
    @Test
    func cleanupDefinitionsNotInChapters_delegatesToStudyEnvironment() throws {
        let chapters = [Chapter.arrange, Chapter.arrange]
        mockStudyEnvironment.cleanupDefinitionsNotInChaptersResult = .success(())
        
        try storyEnvironment.cleanupDefinitionsNotInChapters(chapters)
        
        #expect(mockStudyEnvironment.cleanupDefinitionsNotInChaptersCalled == true)
        #expect(mockStudyEnvironment.cleanupDefinitionsNotInChaptersSpy == chapters)
    }
    
    @Test
    func cleanupOrphanedSentenceAudioFiles_delegatesToStudyEnvironment() throws {
        mockStudyEnvironment.cleanupOrphanedSentenceAudioFilesResult = .success(())
        
        try storyEnvironment.cleanupOrphanedSentenceAudioFiles()
        
        #expect(mockStudyEnvironment.cleanupOrphanedSentenceAudioFilesCalled == true)
    }
    
    @Test
    func settingsUpdatedSubject_returnsSettingsEnvironmentSubject() {
        let expectedSettings = SettingsState.arrange
        
        storyEnvironment.settingsUpdatedSubject.send(expectedSettings)
        
        #expect(storyEnvironment.settingsUpdatedSubject.value == expectedSettings)
    }
    
    @Test
    func goToNextChapterSubject_returnsTextPracticeEnvironmentSubject() {
        mockTextPracticeEnvironment.goToNextChapterSubject.send(())
        
        #expect(storyEnvironment.goToNextChapterSubject.value != nil)
    }
    
    @Test
    func limitReachedSubject_returnsUserLimitEnvironmentSubject() {
        let event = LimitReachedEvent.freeLimit
        
        storyEnvironment.limitReachedSubject.send(event)
        
        #expect(storyEnvironment.limitReachedSubject.value == event)
    }
    
    @Test
    func generateChapterStory_delegatesToTextGenerationService() async throws {
        let previousChapters = [Chapter.arrange]
        let language = Language.spanish
        let difficulty = Difficulty.intermediate
        let voice = Voice.elvira
        let storyPrompt = "A mystery story"
        let expectedChapter = Chapter.arrange(passage: "Generated story")
        
        mockTextGenerationService.generateChapterStoryResult = .success(expectedChapter)
        
        let result = try await storyEnvironment.generateChapterStory(
            previousChapters: previousChapters,
            language: language,
            difficulty: difficulty,
            voice: voice,
            storyPrompt: storyPrompt
        )
        
        #expect(result == expectedChapter)
        #expect(mockTextGenerationService.generateChapterStoryCalled == true)
        #expect(mockTextGenerationService.generateChapterStoryPreviousChaptersSpy == previousChapters)
        #expect(mockTextGenerationService.generateChapterStoryLanguageSpy == language)
        #expect(mockTextGenerationService.generateChapterStoryDifficultySpy == difficulty)
        #expect(mockTextGenerationService.generateChapterStoryVoiceSpy == voice)
        #expect(mockTextGenerationService.generateChapterStoryStoryPromptSpy == storyPrompt)
        #expect(mockLoadingEnvironment.updateLoadingStatusSpy == .writing)
    }
    
    @Test
    func formatStoryIntoSentences_delegatesToTextGenerationService() async throws {
        let chapter = Chapter.arrange(passage: "Story to format")
        let deviceLanguage = Language.english
        let expectedChapter = Chapter.arrange(sentences: [.arrange])
        
        mockTextGenerationService.formatStoryIntoSentencesResult = .success(expectedChapter)
        
        let result = try await storyEnvironment.formatStoryIntoSentences(
            chapter: chapter,
            deviceLanguage: deviceLanguage
        )
        
        #expect(result == expectedChapter)
        #expect(mockTextGenerationService.formatStoryIntoSentencesCalled == true)
        #expect(mockTextGenerationService.formatStoryIntoSentencesChapterSpy == chapter)
        #expect(mockTextGenerationService.formatStoryIntoSentencesDeviceLanguageSpy == deviceLanguage)
        #expect(mockLoadingEnvironment.updateLoadingStatusSpy == .formattingSentences)
    }
}
