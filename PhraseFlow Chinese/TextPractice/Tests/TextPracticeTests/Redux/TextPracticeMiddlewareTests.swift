//
//  TextPracticeMiddlewareTests.swift
//  TextPractice
//
//  Created by Isaac Akalanne on 21/09/2025.
//

import Foundation
import Testing
import Audio
import Settings
import Study
@testable import StudyMocks
import TextGeneration
import TextGenerationMocks
@testable import TextPractice
@testable import TextPracticeMocks

final class TextPracticeMiddlewareTests {
    
    let mockEnvironment: MockTextPracticeEnvironment
    
    init() {
        mockEnvironment = MockTextPracticeEnvironment()
    }
    
    @Test
    func goToNextChapter_callsEnvironmentMethod() async {
        let resultAction = await textPracticeMiddleware(
            .arrange,
            .goToNextChapter,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
        #expect(mockEnvironment.goToNextChapterCalled == true)
    }
    
    @Test
    func setChapter_returnsPrepareToPlayChapter() async {
        let chapter: Chapter = .arrange
        
        let resultAction = await textPracticeMiddleware(
            .arrange,
            .setChapter(chapter),
            mockEnvironment
        )
        
        #expect(resultAction == .prepareToPlayChapter)
    }
    
    @Test
    func prepareToPlayChapter_callsEnvironmentAndReturnsGenerateDefinitions() async {
        let chapter: Chapter = .arrange
        let state: TextPracticeState = .arrange(chapter: chapter)
        
        let resultAction = await textPracticeMiddleware(
            state,
            .prepareToPlayChapter,
            mockEnvironment
        )
        
        #expect(resultAction == .generateDefinitions(chapter, sentenceIndex: 0))
        #expect(mockEnvironment.prepareToPlayChapterCalled == true)
        #expect(mockEnvironment.prepareToPlayChapterSpy == chapter)
    }
    
    @Test
    func playChapter_callsEnvironmentAndSetsVolume() async {
        let word: WordTimeStampData = .arrange
        let speechSpeed: SpeechSpeed = .normal
        let state: TextPracticeState = .arrange(settings: .arrange(speechSpeed: speechSpeed))
        
        let resultAction = await textPracticeMiddleware(
            state,
            .playChapter(fromWord: word),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
        #expect(mockEnvironment.playChapterCalled == true)
        #expect(mockEnvironment.playChapterFromWordSpy == word)
        #expect(mockEnvironment.playChapterSpeechSpeedSpy == speechSpeed)
        #expect(mockEnvironment.setMusicVolumeCalled == true)
        #expect(mockEnvironment.setMusicVolumeSpy == .quiet)
    }
    
    @Test
    func pauseChapter_callsEnvironmentAndRestoresVolume() async {
        let resultAction = await textPracticeMiddleware(
            .arrange,
            .pauseChapter,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
        #expect(mockEnvironment.pauseChapterCalled == true)
        #expect(mockEnvironment.setMusicVolumeCalled == true)
        #expect(mockEnvironment.setMusicVolumeSpy == .normal)
    }
    
    @Test
    func playSound_whenSoundEnabled_playsSound() async {
        let state: TextPracticeState = .arrange(settings: .arrange(shouldPlaySound: true))
        let sound: AppSound = .actionButtonPress
        
        let resultAction = await textPracticeMiddleware(
            state,
            .playSound(sound),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
        #expect(mockEnvironment.playSoundCalled == true)
        #expect(mockEnvironment.playSoundSpy == sound)
    }
    
    @Test
    func playSound_whenSoundDisabled_doesNotPlaySound() async {
        let state: TextPracticeState = .arrange(settings: .arrange(shouldPlaySound: false))
        let sound: AppSound = .actionButtonPress
        
        let resultAction = await textPracticeMiddleware(
            state,
            .playSound(sound),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
        #expect(mockEnvironment.playSoundCalled == false)
    }
    
    @Test
    func selectWord_playsWordAndReturnsShowDefinition() async {
        let word: WordTimeStampData = .arrange
        let speechSpeed: SpeechSpeed = .fast
        let state: TextPracticeState = .arrange(settings: .arrange(speechSpeed: speechSpeed))
        
        let resultAction = await textPracticeMiddleware(
            state,
            .selectWord(word),
            mockEnvironment
        )
        
        #expect(resultAction == .showDefinition(word))
        #expect(mockEnvironment.playWordCalled == true)
        #expect(mockEnvironment.playWordWordSpy == word)
        #expect(mockEnvironment.playWordRateSpy == speechSpeed.playRate)
    }
    
    @Test
    func saveAppSettings_success() async {
        let settings: SettingsState = .arrange
        mockEnvironment.saveAppSettingsResult = .success(())
        
        let resultAction = await textPracticeMiddleware(
            .arrange,
            .saveAppSettings(settings),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
        #expect(mockEnvironment.saveAppSettingsCalled == true)
        #expect(mockEnvironment.saveAppSettingsSpy == settings)
    }
    
    @Test
    func saveAppSettings_error() async {
        let settings: SettingsState = .arrange
        mockEnvironment.saveAppSettingsResult = .failure(.genericError)
        
        let resultAction = await textPracticeMiddleware(
            .arrange,
            .saveAppSettings(settings),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
        #expect(mockEnvironment.saveAppSettingsCalled == true)
    }
    
    @Test
    func generateDefinitions_whenAllDefinitionsExist_returnsOnGeneratedDefinitions() async {
        let sentence: Sentence = .arrange(id: UUID(), timestamps: [.arrange(word: "hello"), .arrange(word: "world")])
        let chapter: Chapter = .arrange(sentences: [sentence])
        let definitions = [
            DefinitionKey(word: "hello", sentenceId: sentence.id): Definition.arrange(timestampData: .arrange(word: "hello"), sentenceId: sentence.id),
            DefinitionKey(word: "world", sentenceId: sentence.id): Definition.arrange(timestampData: .arrange(word: "world"), sentenceId: sentence.id)
        ]
        let state: TextPracticeState = .arrange(chapter: chapter, definitions: definitions)
        
        let resultAction = await textPracticeMiddleware(
            state,
            .generateDefinitions(chapter, sentenceIndex: 0),
            mockEnvironment
        )
        
        let expectedDefinitions = [definitions[DefinitionKey(word: "hello", sentenceId: sentence.id)]!, definitions[DefinitionKey(word: "world", sentenceId: sentence.id)]!]
        #expect(resultAction == .onGeneratedDefinitions(expectedDefinitions, chapter: chapter, sentenceIndex: 0))
    }
    
    @Test
    func generateDefinitions_success() async {
        let sentence: Sentence = .arrange
        let chapter: Chapter = .arrange(sentences: [sentence])
        let state: TextPracticeState = .arrange(chapter: chapter)
        let expectedDefinitions: [Definition] = [.arrange]
        
        let mockStudyEnvironment = mockEnvironment.studyEnvironment as! MockStudyEnvironment
        mockStudyEnvironment.fetchDefinitionsResult = .success(expectedDefinitions)
        
        let resultAction = await textPracticeMiddleware(
            state,
            .generateDefinitions(chapter, sentenceIndex: 0),
            mockEnvironment
        )
        
        #expect(resultAction == .onGeneratedDefinitions(expectedDefinitions, chapter: chapter, sentenceIndex: 0))
        #expect(mockEnvironment.saveDefinitionsCalled == true)
        #expect(mockEnvironment.saveDefinitionsSpy == expectedDefinitions)
    }
    
    @Test
    func generateDefinitions_error() async {
        let sentence: Sentence = .arrange
        let chapter: Chapter = .arrange(sentences: [sentence])
        let state: TextPracticeState = .arrange(chapter: chapter)
        
        let mockStudyEnvironment = mockEnvironment.studyEnvironment as! MockStudyEnvironment
        mockStudyEnvironment.fetchDefinitionsResult = .failure(.genericError)
        
        let resultAction = await textPracticeMiddleware(
            state,
            .generateDefinitions(chapter, sentenceIndex: 0),
            mockEnvironment
        )
        
        #expect(resultAction == .failedToLoadDefinitions)
    }
    
    @Test
    func generateDefinitions_invalidSentenceIndex_returnsNil() async {
        let chapter: Chapter = .arrange(sentences: [.arrange])
        let state: TextPracticeState = .arrange(chapter: chapter)
        
        let resultAction = await textPracticeMiddleware(
            state,
            .generateDefinitions(chapter, sentenceIndex: 5),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func onGeneratedDefinitions_hasMoreSentences_continuesGenerating() async {
        let sentences: [Sentence] = [.arrange, .arrange, .arrange]
        let chapter: Chapter = .arrange(sentences: sentences)
        let definitions: [Definition] = [.arrange]
        
        let resultAction = await textPracticeMiddleware(
            .arrange,
            .onGeneratedDefinitions(definitions, chapter: chapter, sentenceIndex: 0),
            mockEnvironment
        )
        
        #expect(resultAction == .generateDefinitions(chapter, sentenceIndex: 1))
    }
    
    @Test
    func onGeneratedDefinitions_lastSentence_returnsNil() async {
        let sentences: [Sentence] = [.arrange]
        let chapter: Chapter = .arrange(sentences: sentences)
        let definitions: [Definition] = [.arrange]
        
        let resultAction = await textPracticeMiddleware(
            .arrange,
            .onGeneratedDefinitions(definitions, chapter: chapter, sentenceIndex: 0),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func defineWord_withExistingDefinition_returnsOnDefinedWord() async {
        let word: WordTimeStampData = .arrange(word: "test")
        let sentence: Sentence = .arrange
        let chapter: Chapter = .arrange(currentSentence: sentence)
        let definition: Definition = .arrange(timestampData: word, sentenceId: sentence.id)
        let definitions = [DefinitionKey(word: word.word, sentenceId: sentence.id): definition]
        let state: TextPracticeState = .arrange(chapter: chapter, definitions: definitions)
        
        let resultAction = await textPracticeMiddleware(
            state,
            .defineWord(word),
            mockEnvironment
        )
        
        #expect(resultAction == .onDefinedWord(definition))
    }
    
    @Test
    func defineWord_withoutDefinition_returnsFailure() async {
        let word: WordTimeStampData = .arrange
        let sentence: Sentence = .arrange
        let chapter: Chapter = .arrange(currentSentence: sentence)
        let state: TextPracticeState = .arrange(chapter: chapter)
        
        let resultAction = await textPracticeMiddleware(
            state,
            .defineWord(word),
            mockEnvironment
        )
        
        #expect(resultAction == .failedToDefineWord)
    }
    
    @Test
    func defineWord_withoutCurrentSentence_returnsFailure() async {
        let word: WordTimeStampData = .arrange
        let chapter: Chapter = .arrange(currentSentence: nil)
        let state: TextPracticeState = .arrange(chapter: chapter)
        
        let resultAction = await textPracticeMiddleware(
            state,
            .defineWord(word),
            mockEnvironment
        )
        
        #expect(resultAction == .failedToDefineWord)
    }
    
    @Test
    func updateCurrentSentence_returnsClearDefinition() async {
        let sentence: Sentence = .arrange
        
        let resultAction = await textPracticeMiddleware(
            .arrange,
            .updateCurrentSentence(sentence),
            mockEnvironment
        )
        
        #expect(resultAction == .clearDefinition)
    }
    
    @Test
    func addDefinitions_returnsNil() async {
        let definitions: [Definition] = [.arrange]
        
        let resultAction = await textPracticeMiddleware(
            .arrange,
            .addDefinitions(definitions),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func setPlaybackTime_returnsNil() async {
        let resultAction = await textPracticeMiddleware(
            .arrange,
            .setPlaybackTime(10.0),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func refreshAppSettings_returnsNil() async {
        let settings: SettingsState = .arrange
        
        let resultAction = await textPracticeMiddleware(
            .arrange,
            .refreshAppSettings(settings),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func hideDefinition_returnsNil() async {
        let resultAction = await textPracticeMiddleware(
            .arrange,
            .hideDefinition,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func failedToLoadDefinitions_returnsNil() async {
        let resultAction = await textPracticeMiddleware(
            .arrange,
            .failedToLoadDefinitions,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func onDefinedWord_returnsNil() async {
        let definition: Definition = .arrange
        
        let resultAction = await textPracticeMiddleware(
            .arrange,
            .onDefinedWord(definition),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func failedToDefineWord_returnsNil() async {
        let resultAction = await textPracticeMiddleware(
            .arrange,
            .failedToDefineWord,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func clearDefinition_returnsNil() async {
        let resultAction = await textPracticeMiddleware(
            .arrange,
            .clearDefinition,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
}
