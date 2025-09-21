//
//  StoryMiddlewareTests.swift
//  Story
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Testing
import Foundation
import Settings
import TextGeneration
@testable import Story
@testable import StoryMocks

final class StoryMiddlewareTests {
    
    let mockEnvironment: MockStoryEnvironment
    
    init() {
        mockEnvironment = MockStoryEnvironment()
    }
    
    @Test
    func createChapter_whenHasRemainingCharacters_generatesText() async {
        let state: StoryState = .arrange(settings: .arrange(usedCharacters: 50))
        
        let resultAction = await storyMiddleware(
            state,
            .createChapter(.newStory),
            mockEnvironment
        )
        
        #expect(resultAction == .generateText(.newStory))
    }
    
    @Test
    func createChapter_whenNoRemainingCharacters_failsToCreateChapter() async {
        let state: StoryState = .arrange(settings: .arrange(usedCharacters: 9_999_999_999))
        
        let resultAction = await storyMiddleware(
            state,
            .createChapter(.newStory),
            mockEnvironment
        )
        
        #expect(resultAction == .failedToCreateChapter)
    }
    
    @Test
    func failedToCreateChapter_whenNoCharactersRemaining_triggersLimitReached() async {
        let state: StoryState = .arrange(settings: .arrange(usedCharacters: 9_999_999_999, subscriptionLevel: .free))
        
        let resultAction = await storyMiddleware(
            state,
            .failedToCreateChapter,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
        #expect(mockEnvironment.limitReachedCalled == true)
        #expect(mockEnvironment.limitReachedSpy == .freeLimit)
    }
    
    @Test
    func failedToCreateChapter_whenHasCharacters_doesNotTriggerLimitReached() async {
        let state: StoryState = .arrange(settings: .arrange(usedCharacters: 50))
        
        let resultAction = await storyMiddleware(
            state,
            .failedToCreateChapter,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
        #expect(mockEnvironment.limitReachedCalled == false)
    }
    
    @Test
    func generateText_success_returnsOnGeneratedText() async {
        let expectedChapter: Chapter = .arrange(title: "Test Chapter")
        mockEnvironment.generateChapterStoryResult = .success(expectedChapter)
        
        let resultAction = await storyMiddleware(
            .arrange,
            .generateText(.newStory),
            mockEnvironment
        )
        
        #expect(resultAction == .onGeneratedText(expectedChapter))
        #expect(mockEnvironment.generateChapterStoryCalled == true)
    }
    
    @Test
    func generateText_error_returnsFailedToCreateChapter() async {
        mockEnvironment.generateChapterStoryResult = .failure(.genericError)
        
        let resultAction = await storyMiddleware(
            .arrange,
            .generateText(.newStory),
            mockEnvironment
        )
        
        #expect(resultAction == .failedToCreateChapter)
        #expect(mockEnvironment.generateChapterStoryCalled == true)
    }
    
    @Test
    func generateText_withExistingStory_passesExistingChapters() async {
        let storyId = UUID()
        let existingChapter: Chapter = .arrange(storyId: storyId)
        let state: StoryState = .arrange(storyChapters: [storyId: [existingChapter]])
        let expectedChapter = Chapter.arrange
        
        mockEnvironment.generateChapterStoryResult = .success(expectedChapter)
        
        let resultAction = await storyMiddleware(
            state,
            .generateText(.existingStory(storyId)),
            mockEnvironment
        )
        
        #expect(resultAction == .onGeneratedText(expectedChapter))
        #expect(mockEnvironment.generateChapterStoryPreviousChaptersSpy == [existingChapter])
    }
    
    @Test
    func onGeneratedText_returnsFormatSentences() async {
        let chapter: Chapter = .arrange
        
        let resultAction = await storyMiddleware(
            .arrange,
            .onGeneratedText(chapter),
            mockEnvironment
        )
        
        #expect(resultAction == .formatSentences(chapter))
    }
    
    @Test
    func formatSentences_success_returnsOnFormattedSentences() async {
        let chapter: Chapter = .arrange(passage: "Test story text")
        let expectedChapter: Chapter = .arrange(title: "Formatted Chapter", sentences: [.arrange])
        mockEnvironment.formatStoryIntoSentencesResult = .success(expectedChapter)
        
        let resultAction = await storyMiddleware(
            .arrange,
            .formatSentences(chapter),
            mockEnvironment
        )
        
        #expect(resultAction == .onFormattedSentences(expectedChapter))
        #expect(mockEnvironment.formatStoryIntoSentencesCalled == true)
        #expect(mockEnvironment.formatStoryIntoSentencesChapterSpy == chapter)
    }
    
    @Test
    func formatSentences_error_returnsFailedToCreateChapter() async {
        let chapter: Chapter = .arrange(passage: "Test story text")
        mockEnvironment.formatStoryIntoSentencesResult = .failure(.genericError)
        
        let resultAction = await storyMiddleware(
            .arrange,
            .formatSentences(chapter),
            mockEnvironment
        )
        
        #expect(resultAction == .failedToCreateChapter)
        #expect(mockEnvironment.formatStoryIntoSentencesCalled == true)
    }
    
    @Test
    func onFormattedSentences_returnsGenerateImage() async {
        let chapter: Chapter = .arrange
        
        let resultAction = await storyMiddleware(
            .arrange,
            .onFormattedSentences(chapter),
            mockEnvironment
        )
        
        #expect(resultAction == .generateImage(chapter))
    }
    
    @Test
    func generateImage_success_returnsOnGeneratedImage() async {
        let chapter: Chapter = .arrange
        let expectedChapter: Chapter = .arrange(title: "With Image")
        mockEnvironment.generateImageForChapterResult = .success(expectedChapter)
        
        let resultAction = await storyMiddleware(
            .arrange,
            .generateImage(chapter),
            mockEnvironment
        )
        
        #expect(resultAction == .onGeneratedImage(expectedChapter))
        #expect(mockEnvironment.generateImageForChapterCalled == true)
        #expect(mockEnvironment.generateImageForChapterChapterSpy == chapter)
    }
    
    @Test
    func generateImage_error_returnsFailedToCreateChapter() async {
        let chapter: Chapter = .arrange
        mockEnvironment.generateImageForChapterResult = .failure(.genericError)
        
        let resultAction = await storyMiddleware(
            .arrange,
            .generateImage(chapter),
            mockEnvironment
        )
        
        #expect(resultAction == .failedToCreateChapter)
        #expect(mockEnvironment.generateImageForChapterCalled == true)
    }
    
    @Test
    func onGeneratedImage_returnsGenerateSpeech() async {
        let chapter: Chapter = .arrange
        
        let resultAction = await storyMiddleware(
            .arrange,
            .onGeneratedImage(chapter),
            mockEnvironment
        )
        
        #expect(resultAction == .generateSpeech(chapter))
    }
    
    @Test
    func generateSpeech_success_returnsOnGeneratedSpeech() async {
        let chapter: Chapter = .arrange
        let expectedChapter: Chapter = .arrange(title: "With Speech")
        mockEnvironment.generateSpeechForChapterResult = .success(expectedChapter)
        
        let resultAction = await storyMiddleware(
            .arrange,
            .generateSpeech(chapter),
            mockEnvironment
        )
        
        #expect(resultAction == .onGeneratedSpeech(expectedChapter))
        #expect(mockEnvironment.generateSpeechForChapterCalled == true)
        #expect(mockEnvironment.generateSpeechForChapterSpy == chapter)
    }
    
    @Test
    func generateSpeech_error_returnsFailedToCreateChapter() async {
        let chapter: Chapter = .arrange
        mockEnvironment.generateSpeechForChapterResult = .failure(.genericError)
        
        let resultAction = await storyMiddleware(
            .arrange,
            .generateSpeech(chapter),
            mockEnvironment
        )
        
        #expect(resultAction == .failedToCreateChapter)
        #expect(mockEnvironment.generateSpeechForChapterCalled == true)
    }
    
    @Test
    func onGeneratedSpeech_returnsGenerateDefinitions() async {
        let chapter: Chapter = .arrange
        
        let resultAction = await storyMiddleware(
            .arrange,
            .onGeneratedSpeech(chapter),
            mockEnvironment
        )
        
        #expect(resultAction == .generateDefinitions(chapter))
    }
    
    @Test
    func generateDefinitions_success_returnsOnGeneratedDefinitions() async {
        let chapter: Chapter = .arrange
        let expectedChapter: Chapter = .arrange(title: "With Definitions")
        mockEnvironment.generateDefinitionsForChapterResult = .success(expectedChapter)
        
        let resultAction = await storyMiddleware(
            .arrange,
            .generateDefinitions(chapter),
            mockEnvironment
        )
        
        #expect(resultAction == .onGeneratedDefinitions(expectedChapter))
        #expect(mockEnvironment.generateDefinitionsForChapterCalled == true)
        #expect(mockEnvironment.generateDefinitionsForChapterChapterSpy == chapter)
    }
    
    @Test
    func generateDefinitions_error_returnsFailedToCreateChapter() async {
        let chapter: Chapter = .arrange
        mockEnvironment.generateDefinitionsForChapterResult = .failure(.genericError)
        
        let resultAction = await storyMiddleware(
            .arrange,
            .generateDefinitions(chapter),
            mockEnvironment
        )
        
        #expect(resultAction == .failedToCreateChapter)
        #expect(mockEnvironment.generateDefinitionsForChapterCalled == true)
    }
    
    @Test
    func onGeneratedDefinitions_success_savesAndReturnsOnCreatedChapter() async {
        let chapter: Chapter = .arrange
        mockEnvironment.saveChapterResult = .success(())
        
        let resultAction = await storyMiddleware(
            .arrange,
            .onGeneratedDefinitions(chapter),
            mockEnvironment
        )
        
        #expect(resultAction == .onCreatedChapter(chapter))
        #expect(mockEnvironment.saveChapterCalled == true)
        #expect(mockEnvironment.saveChapterSpy == chapter)
    }
    
    @Test
    func onGeneratedDefinitions_saveError_returnsFailedToCreateChapter() async {
        let chapter: Chapter = .arrange
        mockEnvironment.saveChapterResult = .failure(.genericError)
        
        let resultAction = await storyMiddleware(
            .arrange,
            .onGeneratedDefinitions(chapter),
            mockEnvironment
        )
        
        #expect(resultAction == .failedToCreateChapter)
        #expect(mockEnvironment.saveChapterCalled == true)
    }
    
    @Test
    func loadStories_success_returnsOnLoadedStories() async {
        let expectedChapters: [Chapter] = [.arrange(title: "Chapter 1"), .arrange(title: "Chapter 2")]
        mockEnvironment.loadAllChaptersResult = .success(expectedChapters)
        
        let resultAction = await storyMiddleware(
            .arrange,
            .loadStories,
            mockEnvironment
        )
        
        #expect(resultAction == .onLoadedStories(expectedChapters))
        #expect(mockEnvironment.loadAllChaptersCalled == true)
        #expect(mockEnvironment.cleanupDefinitionsNotInChaptersCalled == true)
        #expect(mockEnvironment.cleanupOrphanedSentenceAudioFilesCalled == true)
        #expect(mockEnvironment.cleanupDefinitionsNotInChaptersSpy == expectedChapters)
    }
    
    @Test
    func loadStories_error_returnsFailedToLoadStoriesAndDefinitions() async {
        mockEnvironment.loadAllChaptersResult = .failure(.genericError)
        
        let resultAction = await storyMiddleware(
            .arrange,
            .loadStories,
            mockEnvironment
        )
        
        #expect(resultAction == .failedToLoadStoriesAndDefinitions)
        #expect(mockEnvironment.loadAllChaptersCalled == true)
    }
    
    @Test
    func deleteStory_success_returnsOnDeletedStory() async {
        let storyId = UUID()
        let chapters: [Chapter] = [.arrange(storyId: storyId), .arrange(storyId: storyId)]
        let state: StoryState = .arrange(storyChapters: [storyId: chapters])
        mockEnvironment.deleteChapterResult = .success(())
        
        let resultAction = await storyMiddleware(
            state,
            .deleteStory(storyId),
            mockEnvironment
        )
        
        #expect(resultAction == .onDeletedStory(storyId))
        #expect(mockEnvironment.deleteChapterCalled == true)
    }
    
    @Test
    func deleteStory_error_returnsFailedToDeleteStory() async {
        let storyId = UUID()
        let chapters: [Chapter] = [.arrange(storyId: storyId)]
        let state: StoryState = .arrange(storyChapters: [storyId: chapters])
        mockEnvironment.deleteChapterResult = .failure(.genericError)
        
        let resultAction = await storyMiddleware(
            state,
            .deleteStory(storyId),
            mockEnvironment
        )
        
        #expect(resultAction == .failedToDeleteStory)
        #expect(mockEnvironment.deleteChapterCalled == true)
    }
    
    @Test
    func saveChapter_success_returnsOnSavedChapter() async {
        let chapter: Chapter = .arrange
        mockEnvironment.saveChapterResult = .success(())
        
        let resultAction = await storyMiddleware(
            .arrange,
            .saveChapter(chapter),
            mockEnvironment
        )
        
        #expect(resultAction == .onSavedChapter(chapter))
        #expect(mockEnvironment.saveChapterCalled == true)
        #expect(mockEnvironment.saveChapterSpy == chapter)
    }
    
    @Test
    func saveChapter_error_returnsFailedToSaveChapter() async {
        let chapter: Chapter = .arrange
        mockEnvironment.saveChapterResult = .failure(.genericError)
        
        let resultAction = await storyMiddleware(
            .arrange,
            .saveChapter(chapter),
            mockEnvironment
        )
        
        #expect(resultAction == .failedToSaveChapter)
        #expect(mockEnvironment.saveChapterCalled == true)
    }
    
    @Test
    func goToNextChapter_withCurrentChapter_savesThatChapter() async {
        let currentChapter: Chapter = .arrange
        let state: StoryState = .arrange(currentChapter: currentChapter)
        
        let resultAction = await storyMiddleware(
            state,
            .goToNextChapter,
            mockEnvironment
        )
        
        #expect(resultAction == .saveChapter(currentChapter))
    }
    
    @Test
    func goToNextChapter_withoutCurrentChapter_returnsNil() async {
        let state: StoryState = .arrange(currentChapter: nil)
        
        let resultAction = await storyMiddleware(
            state,
            .goToNextChapter,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func playSound_whenSoundEnabled_playsSound() async {
        let state: StoryState = .arrange(settings: .arrange(shouldPlaySound: true))
        
        let resultAction = await storyMiddleware(
            state,
            .playSound(.actionButtonPress),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
        #expect(mockEnvironment.playSoundCalled == true)
        #expect(mockEnvironment.playSoundSpy == .actionButtonPress)
    }
    
    @Test
    func playSound_whenSoundDisabled_doesNotPlaySound() async {
        let state: StoryState = .arrange(settings: .arrange(shouldPlaySound: false))
        
        let resultAction = await storyMiddleware(
            state,
            .playSound(.actionButtonPress),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
        #expect(mockEnvironment.playSoundCalled == false)
    }
    
    @Test
    func beginGetNextChapter_whenIsLastChapter_createsNewChapter() async {
        let storyId = UUID()
        let currentChapter: Chapter = .arrange(storyId: storyId)
        let state: StoryState = .arrange(
            currentChapter: currentChapter,
            storyChapters: [storyId: [currentChapter]]
        )
        
        let resultAction = await storyMiddleware(
            state,
            .beginGetNextChapter,
            mockEnvironment
        )
        
        #expect(resultAction == .createChapter(.existingStory(storyId)))
    }
    
    @Test
    func beginGetNextChapter_whenNotLastChapter_goesToNextChapter() async {
        let storyId = UUID()
        let currentChapter: Chapter = .arrange(storyId: storyId)
        let nextChapter: Chapter = .arrange(storyId: storyId)
        let state: StoryState = .arrange(
            currentChapter: currentChapter,
            storyChapters: [storyId: [currentChapter, nextChapter]]
        )
        
        let resultAction = await storyMiddleware(
            state,
            .beginGetNextChapter,
            mockEnvironment
        )
        
        #expect(resultAction == .goToNextChapter)
    }
    
    @Test
    func saveAppSettings_savesSettings() async {
        let settings: SettingsState = .arrange(language: .mandarinChinese)
        mockEnvironment.saveAppSettingsResult = .success(())
        
        let resultAction = await storyMiddleware(
            .arrange,
            .saveAppSettings(settings),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
        #expect(mockEnvironment.saveAppSettingsCalled == true)
        #expect(mockEnvironment.saveAppSettingsSpy == settings)
    }
    
    @Test
    func updateLanguage_whenSoundEnabled_playsTabPress() async {
        let state: StoryState = .arrange(settings: .arrange(shouldPlaySound: true))
        
        let resultAction = await storyMiddleware(
            state,
            .updateLanguage(.mandarinChinese),
            mockEnvironment
        )
        
        #expect(resultAction == .saveAppSettings(state.settings))
        #expect(mockEnvironment.playSoundCalled == true)
        #expect(mockEnvironment.playSoundSpy == .tabPress)
    }
    
    @Test
    func updateLanguage_whenSoundDisabled_doesNotPlaySound() async {
        let state: StoryState = .arrange(settings: .arrange(shouldPlaySound: false))
        
        let resultAction = await storyMiddleware(
            state,
            .updateLanguage(.spanish),
            mockEnvironment
        )
        
        #expect(resultAction == .saveAppSettings(state.settings))
        #expect(mockEnvironment.playSoundCalled == false)
    }
    
    @Test
    func failedToLoadStoriesAndDefinitions_returnsNil() async {
        let resultAction = await storyMiddleware(
            .arrange,
            .failedToLoadStoriesAndDefinitions,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func failedToDeleteStory_returnsNil() async {
        let resultAction = await storyMiddleware(
            .arrange,
            .failedToDeleteStory,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func failedToSaveChapter_returnsNil() async {
        let resultAction = await storyMiddleware(
            .arrange,
            .failedToSaveChapter,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func onSavedChapter_returnsNil() async {
        let resultAction = await storyMiddleware(
            .arrange,
            .onSavedChapter(.arrange),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func onDeletedStory_returnsNil() async {
        let resultAction = await storyMiddleware(
            .arrange,
            .onDeletedStory(UUID()),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func onCreatedChapter_returnsNil() async {
        let resultAction = await storyMiddleware(
            .arrange,
            .onCreatedChapter(.arrange),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func selectChapter_returnsNil() async {
        let resultAction = await storyMiddleware(
            .arrange,
            .selectChapter(.arrange),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func onLoadedStories_returnsNil() async {
        let resultAction = await storyMiddleware(
            .arrange,
            .onLoadedStories([.arrange]),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func refreshAppSettings_returnsNil() async {
        let resultAction = await storyMiddleware(
            .arrange,
            .refreshAppSettings(.arrange),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
}
