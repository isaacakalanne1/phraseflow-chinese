//
//  TextPracticeReducerTests.swift
//  TextPractice
//
//  Created by Isaac Akalanne on 21/09/2025.
//

import Testing
import Audio
import Settings
import SettingsMocks
import Study
import StudyMocks
import TextGeneration
import TextGenerationMocks
@testable import TextPractice
@testable import TextPracticeMocks

final class TextPracticeReducerTests {
    
    @Test
    func setChapter_updatesChapter() {
        let initialState = TextPracticeState.arrange
        let newChapter = Chapter.arrange(title: "New Chapter")
        var expectedState = initialState
        expectedState.chapter = newChapter
        
        let newState = textPracticeReducer(
            initialState,
            .setChapter(newChapter)
        )
        
        #expect(newState == expectedState)
    }
    
    @Test
    func addDefinitions_addsNewDefinitions() {
        let initialState = TextPracticeState.arrange
        let word1 = WordTimeStampData.arrange(word: "hello")
        let word2 = WordTimeStampData.arrange(word: "world")
        let sentence = Sentence.arrange
        let definitions = [
            Definition.arrange(timestampData: word1, sentence: sentence),
            Definition.arrange(timestampData: word2, sentence: sentence)
        ]
        
        var expectedState = initialState
        expectedState.definitions[DefinitionKey(word: word1.word, sentenceId: sentence.id)] = definitions[0]
        expectedState.definitions[DefinitionKey(word: word2.word, sentenceId: sentence.id)] = definitions[1]
        
        let newState = textPracticeReducer(
            initialState,
            .addDefinitions(definitions)
        )
        
        #expect(newState == expectedState)
    }
    
    @Test
    func addDefinitions_doesNotDuplicateExistingDefinitions() {
        let word = WordTimeStampData.arrange(word: "test")
        let sentence = Sentence.arrange
        let existingDefinition = Definition.arrange(timestampData: word, sentence: sentence)
        let key = DefinitionKey(word: word.word, sentenceId: sentence.id)
        
        let initialState = TextPracticeState.arrange(
            definitions: [key: existingDefinition]
        )
        
        let newDefinition = Definition.arrange(
            timestampData: word,
            sentence: sentence,
            detail: WordDefinition.arrange(word: "updated")
        )
        
        let newState = textPracticeReducer(
            initialState,
            .addDefinitions([newDefinition])
        )
        
        #expect(newState == initialState)
        #expect(newState.definitions.count == 1)
    }
    
    @Test
    func onGeneratedDefinitions_addsDefinitions() {
        let initialState = TextPracticeState.arrange
        let word = WordTimeStampData.arrange(word: "test")
        let sentence = Sentence.arrange
        let definitions = [
            Definition.arrange(timestampData: word, sentence: sentence)
        ]
        let chapter = Chapter.arrange
        
        var expectedState = initialState
        let key = DefinitionKey(word: word.word, sentenceId: sentence.id)
        expectedState.definitions[key] = definitions[0]
        
        let newState = textPracticeReducer(
            initialState,
            .onGeneratedDefinitions(definitions, chapter: chapter, sentenceIndex: 0)
        )
        
        #expect(newState == expectedState)
    }
    
    @Test
    func showDefinition_withCurrentSentence_setsDefinitionAndViewState() {
        let word = WordTimeStampData.arrange(word: "test")
        let sentence = Sentence.arrange
        let definition = Definition.arrange(
            timestampData: word,
            sentence: sentence,
            hasBeenSeen: false
        )
        let key = DefinitionKey(word: word.word, sentenceId: sentence.id)
        let chapter = Chapter.arrange(currentSentence: sentence)
        
        let initialState = TextPracticeState.arrange(
            chapter: chapter,
            definitions: [key: definition],
            selectedDefinition: nil,
            viewState: .normal
        )
        
        var expectedState = initialState
        expectedState.selectedDefinition = definition
        expectedState.viewState = .showDefinition
        expectedState.definitions[key]?.hasBeenSeen = true
        expectedState.definitions[key]?.creationDate = .now
        
        let newState = textPracticeReducer(
            initialState,
            .showDefinition(word)
        )
        
        #expect(newState.selectedDefinition == definition)
        #expect(newState.viewState == .showDefinition)
        #expect(newState.definitions[key]?.hasBeenSeen == true)
        #expect(newState.definitions[key]?.creationDate != nil)
    }
    
    @Test
    func showDefinition_withoutCurrentSentence_doesNotChangeState() {
        let word = WordTimeStampData.arrange(word: "test")
        let chapter = Chapter.arrange(currentSentence: nil)
        
        let initialState = TextPracticeState.arrange(
            chapter: chapter,
            selectedDefinition: nil,
            viewState: .normal
        )
        
        let newState = textPracticeReducer(
            initialState,
            .showDefinition(word)
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func showDefinition_withoutMatchingDefinition_setsViewStateButNoDefinition() {
        let word = WordTimeStampData.arrange(word: "test")
        let sentence = Sentence.arrange
        let chapter = Chapter.arrange(currentSentence: sentence)
        
        let initialState = TextPracticeState.arrange(
            chapter: chapter,
            definitions: [:],
            selectedDefinition: nil,
            viewState: .normal
        )
        
        var expectedState = initialState
        expectedState.viewState = .showDefinition
        
        let newState = textPracticeReducer(
            initialState,
            .showDefinition(word)
        )
        
        #expect(newState == expectedState)
        #expect(newState.selectedDefinition == nil)
    }
    
    @Test
    func hideDefinition_clearsDefinitionAndResetsViewState() {
        let definition = Definition.arrange
        let initialState = TextPracticeState.arrange(
            selectedDefinition: definition,
            viewState: .showDefinition
        )
        
        var expectedState = initialState
        expectedState.selectedDefinition = nil
        expectedState.viewState = .normal
        
        let newState = textPracticeReducer(
            initialState,
            .hideDefinition
        )
        
        #expect(newState == expectedState)
    }
    
    @Test
    func selectWord_updatesPlaybackTime() {
        let word = WordTimeStampData.arrange(time: 42.5)
        let initialState = TextPracticeState.arrange(
            chapter: .arrange(currentPlaybackTime: 0)
        )
        
        var expectedState = initialState
        expectedState.chapter.currentPlaybackTime = 42.5
        
        let newState = textPracticeReducer(
            initialState,
            .selectWord(word, playAudio: true)
        )
        
        #expect(newState == expectedState)
    }
    
    @Test
    func setPlaybackTime_updatesTime() {
        let initialState = TextPracticeState.arrange(
            chapter: .arrange(currentPlaybackTime: 0)
        )
        
        var expectedState = initialState
        expectedState.chapter.currentPlaybackTime = 100.5
        
        let newState = textPracticeReducer(
            initialState,
            .setPlaybackTime(100.5)
        )
        
        #expect(newState == expectedState)
    }
    
    @Test
    func updateCurrentSentence_updatesSentence() {
        let newSentence = Sentence.arrange(
            translation: "Bonjour",
            original: "Hello"
        )
        let initialState = TextPracticeState.arrange(
            chapter: .arrange(currentSentence: nil)
        )
        
        var expectedState = initialState
        expectedState.chapter.currentSentence = newSentence
        
        let newState = textPracticeReducer(
            initialState,
            .updateCurrentSentence(newSentence)
        )
        
        #expect(newState == expectedState)
    }
    
    @Test
    func playChapter_setsIsPlayingChapterAudioTrue() {
        let word = WordTimeStampData.arrange
        let initialState = TextPracticeState.arrange(
            isPlayingChapterAudio: false
        )
        
        var expectedState = initialState
        expectedState.isPlayingChapterAudio = true
        
        let newState = textPracticeReducer(
            initialState,
            .playChapter(fromWord: word)
        )
        
        #expect(newState == expectedState)
    }
    
    @Test
    func pauseChapter_setsIsPlayingChapterAudioFalse() {
        let initialState = TextPracticeState.arrange(
            isPlayingChapterAudio: true
        )
        
        var expectedState = initialState
        expectedState.isPlayingChapterAudio = false
        
        let newState = textPracticeReducer(
            initialState,
            .pauseChapter
        )
        
        #expect(newState == expectedState)
    }
    
    @Test
    func refreshAppSettings_updatesSettings() {
        let initialState = TextPracticeState.arrange(
            settings: .arrange(voice: .elvira)
        )
        
        let newSettings = SettingsState.arrange(
            isShowingEnglish: false,
            voice: .denise,
            difficulty: .advanced
        )
        
        var expectedState = initialState
        expectedState.settings = newSettings
        
        let newState = textPracticeReducer(
            initialState,
            .refreshAppSettings(newSettings)
        )
        
        #expect(newState == expectedState)
    }
    
    @Test
    func onDefinedWord_setsDefinitionAndViewState() {
        let word = WordTimeStampData.arrange(word: "test")
        let sentence = Sentence.arrange
        let definition = Definition.arrange(
            timestampData: word,
            sentence: sentence
        )
        let key = DefinitionKey(word: word.word, sentenceId: sentence.id)
        
        let initialState = TextPracticeState.arrange(
            definitions: [key: definition],
            selectedDefinition: nil,
            viewState: .normal
        )
        
        var expectedState = initialState
        expectedState.selectedDefinition = definition
        expectedState.viewState = .showDefinition
        expectedState.definitions[key]?.hasBeenSeen = true
        expectedState.definitions[key]?.creationDate = .now
        
        let newState = textPracticeReducer(
            initialState,
            .onDefinedWord(definition)
        )
        
        #expect(newState.selectedDefinition == definition)
        #expect(newState.viewState == .showDefinition)
        #expect(newState.definitions[key]?.hasBeenSeen == true)
        #expect(newState.definitions[key]?.creationDate != nil)
    }
    
    @Test
    func clearDefinition_clearsDefinitionAndResetsViewState() {
        let definition = Definition.arrange
        let initialState = TextPracticeState.arrange(
            selectedDefinition: definition,
            viewState: .showDefinition
        )
        
        var expectedState = initialState
        expectedState.selectedDefinition = nil
        expectedState.viewState = .normal
        
        let newState = textPracticeReducer(
            initialState,
            .clearDefinition
        )
        
        #expect(newState == expectedState)
    }
    
    @Test
    func goToNextChapter_doesNotChangeState() {
        let state = TextPracticeState.arrange
        
        let newState = textPracticeReducer(
            state,
            .goToNextChapter
        )
        
        #expect(newState == state)
    }
    
    @Test
    func saveAppSettings_doesNotChangeState() {
        let state = TextPracticeState.arrange
        let settings = SettingsState.arrange
        
        let newState = textPracticeReducer(
            state,
            .saveAppSettings(settings)
        )
        
        #expect(newState == state)
    }
    
    @Test
    func generateDefinitions_doesNotChangeState() {
        let state = TextPracticeState.arrange
        let chapter = Chapter.arrange
        
        let newState = textPracticeReducer(
            state,
            .generateDefinitions(chapter, sentenceIndex: 0)
        )
        
        #expect(newState == state)
    }
    
    @Test
    func failedToLoadDefinitions_doesNotChangeState() {
        let state = TextPracticeState.arrange
        
        let newState = textPracticeReducer(
            state,
            .failedToLoadDefinitions
        )
        
        #expect(newState == state)
    }
    
    @Test
    func playWord_doesNotChangeState() {
        let state = TextPracticeState.arrange
        let word = WordTimeStampData.arrange
        
        let newState = textPracticeReducer(
            state,
            .playWord(word)
        )
        
        #expect(newState == state)
    }
    
    @Test
    func defineWord_doesNotChangeState() {
        let state = TextPracticeState.arrange
        let word = WordTimeStampData.arrange
        
        let newState = textPracticeReducer(
            state,
            .defineWord(word)
        )
        
        #expect(newState == state)
    }
    
    @Test
    func failedToDefineWord_doesNotChangeState() {
        let state = TextPracticeState.arrange
        
        let newState = textPracticeReducer(
            state,
            .failedToDefineWord
        )
        
        #expect(newState == state)
    }
    
    @Test
    func prepareToPlayChapter_doesNotChangeState() {
        let state = TextPracticeState.arrange
        
        let newState = textPracticeReducer(
            state,
            .prepareToPlayChapter
        )
        
        #expect(newState == state)
    }
    
    @Test
    func playSound_doesNotChangeState() {
        let state = TextPracticeState.arrange
        
        let newState = textPracticeReducer(
            state,
            .playSound(.actionButtonPress)
        )
        
        #expect(newState == state)
    }
}
