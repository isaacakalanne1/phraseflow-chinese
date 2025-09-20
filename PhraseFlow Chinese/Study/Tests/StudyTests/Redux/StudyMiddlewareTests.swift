//
//  StudyMiddlewareTests.swift
//  Study
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import AVKit
import Testing
import Foundation
import Settings
import TextGeneration
@testable import Study
@testable import StudyMocks

final class StudyMiddlewareTests {
    
    let mockEnvironment: MockStudyEnvironment
    
    init() {
        mockEnvironment = MockStudyEnvironment()
    }
    
    @Test
    func playStudyWord_playsAudioPlayer() async {
        let audioPlayer = AVPlayer()
        let state: StudyState = .arrange(audioPlayer: audioPlayer)
        
        let resultAction = await studyMiddleware(
            state,
            .playStudyWord,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func prepareToPlayStudyWord_withAudioData_returnsOnPreparedStudyWord() async {
        let audioData = Data("test audio".utf8)
        let definition: Definition = .arrange(audioData: audioData)
        
        let resultAction = await studyMiddleware(
            .arrange,
            .prepareToPlayStudyWord(definition),
            mockEnvironment
        )
        
        if case .onPreparedStudyWord(let player) = resultAction {
            #expect(player != nil)
        } else {
            #expect(Bool(false), "Expected onPreparedStudyWord action")
        }
    }
    
    @Test
    func prepareToPlayStudyWord_withoutAudioData_returnsFailedToPrepareStudyWord() async {
        let definition: Definition = .arrange(audioData: nil)
        
        let resultAction = await studyMiddleware(
            .arrange,
            .prepareToPlayStudyWord(definition),
            mockEnvironment
        )
        
        #expect(resultAction == .failedToPrepareStudyWord)
    }
    
    @Test
    func prepareToPlayStudySentence_withSentenceAudio_returnsOnPreparedStudySentence() async {
        let sentenceId = UUID()
        let definition: Definition = .arrange(sentenceId: sentenceId)
        let audioData = Data("sentence audio".utf8)
        mockEnvironment.loadSentenceAudioResult = .success(audioData)
        
        let resultAction = await studyMiddleware(
            .arrange,
            .prepareToPlayStudySentence(definition),
            mockEnvironment
        )
        
        if case .onPreparedStudySentence(let player) = resultAction {
            #expect(player != nil)
        } else {
            #expect(Bool(false), "Expected onPreparedStudySentence action")
        }
        #expect(mockEnvironment.loadSentenceAudioCalled == true)
        #expect(mockEnvironment.loadSentenceAudioSpy == sentenceId)
    }
    
    @Test
    func prepareToPlayStudySentence_withoutSentenceAudio_returnsFailedToPrepareStudySentence() async {
        let definition: Definition = .arrange
        mockEnvironment.loadSentenceAudioResult = .failure(.genericError)
        
        let resultAction = await studyMiddleware(
            .arrange,
            .prepareToPlayStudySentence(definition),
            mockEnvironment
        )
        
        #expect(resultAction == .failedToPrepareStudySentence)
        #expect(mockEnvironment.loadSentenceAudioCalled == true)
    }
    
    @Test
    func playStudySentence_playsSentenceAudioPlayer() async {
        let sentenceAudioPlayer = AVPlayer()
        let state: StudyState = .arrange(sentenceAudioPlayer: sentenceAudioPlayer)
        
        let resultAction = await studyMiddleware(
            state,
            .playStudySentence,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func pauseStudyAudio_pausesBothAudioPlayers() async {
        let audioPlayer = AVPlayer()
        let sentenceAudioPlayer = AVPlayer()
        let state: StudyState = .arrange(
            audioPlayer: audioPlayer,
            sentenceAudioPlayer: sentenceAudioPlayer
        )
        
        let resultAction = await studyMiddleware(
            state,
            .pauseStudyAudio,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func deleteDefinition_success_returnsNil() async {
        let definition: Definition = .arrange
        mockEnvironment.deleteDefinitionResult = .success(())
        
        let resultAction = await studyMiddleware(
            .arrange,
            .deleteDefinition(definition),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
        #expect(mockEnvironment.deleteDefinitionCalled == true)
        #expect(mockEnvironment.deleteDefinitionSpy == definition.id)
    }
    
    @Test
    func deleteDefinition_error_returnsFailedToDeleteDefinition() async {
        let definition: Definition = .arrange
        mockEnvironment.deleteDefinitionResult = .failure(.genericError)
        
        let resultAction = await studyMiddleware(
            .arrange,
            .deleteDefinition(definition),
            mockEnvironment
        )
        
        #expect(resultAction == .failedToDeleteDefinition)
        #expect(mockEnvironment.deleteDefinitionCalled == true)
    }
    
    @Test
    func playSound_whenSoundEnabled_playsSound() async {
        let state: StudyState = .arrange(settings: .arrange(shouldPlaySound: true))
        
        let resultAction = await studyMiddleware(
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
        let state: StudyState = .arrange(settings: .arrange(shouldPlaySound: false))
        
        let resultAction = await studyMiddleware(
            state,
            .playSound(.actionButtonPress),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
        #expect(mockEnvironment.playSoundCalled == false)
    }
    
    @Test
    func loadDefinitions_success_returnsOnLoadDefinitions() async {
        let expectedDefinitions: [Definition] = [.arrange(hasBeenSeen: true), .arrange(hasBeenSeen: false)]
        mockEnvironment.loadDefinitionsResult = .success(expectedDefinitions)
        
        let resultAction = await studyMiddleware(
            .arrange,
            .loadDefinitions,
            mockEnvironment
        )
        
        #expect(resultAction == .onLoadDefinitions(expectedDefinitions))
        #expect(mockEnvironment.loadDefinitionsCalled == true)
    }
    
    @Test
    func loadDefinitions_error_returnsFailedToLoadDefinitions() async {
        mockEnvironment.loadDefinitionsResult = .failure(.genericError)
        
        let resultAction = await studyMiddleware(
            .arrange,
            .loadDefinitions,
            mockEnvironment
        )
        
        #expect(resultAction == .failedToLoadDefinitions)
        #expect(mockEnvironment.loadDefinitionsCalled == true)
    }
    
    @Test
    func saveDefinitions_success_returnsOnSavedDefinitions() async {
        let definitions: [Definition] = [.arrange, .arrange]
        mockEnvironment.saveDefinitionsResult = .success(())
        
        let resultAction = await studyMiddleware(
            .arrange,
            .saveDefinitions(definitions),
            mockEnvironment
        )
        
        #expect(resultAction == .onSavedDefinitions(definitions))
        #expect(mockEnvironment.saveDefinitionsCalled == true)
        #expect(mockEnvironment.saveDefinitionsSpy == definitions)
    }
    
    @Test
    func saveDefinitions_error_returnsFailedToSaveDefinitions() async {
        let definitions: [Definition] = [.arrange]
        mockEnvironment.saveDefinitionsResult = .failure(.genericError)
        
        let resultAction = await studyMiddleware(
            .arrange,
            .saveDefinitions(definitions),
            mockEnvironment
        )
        
        #expect(resultAction == .failedToSaveDefinitions)
        #expect(mockEnvironment.saveDefinitionsCalled == true)
    }
    
    @Test
    func onSavedDefinitions_returnsAddDefinitions() async {
        let definitions: [Definition] = [.arrange, .arrange]
        
        let resultAction = await studyMiddleware(
            .arrange,
            .onSavedDefinitions(definitions),
            mockEnvironment
        )
        
        #expect(resultAction == .addDefinitions(definitions))
    }
    
    @Test
    func failedToDeleteDefinition_returnsNil() async {
        let resultAction = await studyMiddleware(
            .arrange,
            .failedToDeleteDefinition,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func updateStudiedWord_returnsNil() async {
        let resultAction = await studyMiddleware(
            .arrange,
            .updateStudiedWord(.arrange),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func failedToPrepareStudyWord_returnsNil() async {
        let resultAction = await studyMiddleware(
            .arrange,
            .failedToPrepareStudyWord,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func failedToPrepareStudySentence_returnsNil() async {
        let resultAction = await studyMiddleware(
            .arrange,
            .failedToPrepareStudySentence,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func onPreparedStudySentence_returnsNil() async {
        let resultAction = await studyMiddleware(
            .arrange,
            .onPreparedStudySentence(AVPlayer()),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func updateDisplayStatus_returnsNil() async {
        let resultAction = await studyMiddleware(
            .arrange,
            .updateDisplayStatus(.wordShown),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func onPreparedStudyWord_returnsNil() async {
        let resultAction = await studyMiddleware(
            .arrange,
            .onPreparedStudyWord(AVPlayer()),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func onLoadDefinitions_returnsNil() async {
        let resultAction = await studyMiddleware(
            .arrange,
            .onLoadDefinitions([.arrange]),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func failedToLoadDefinitions_returnsNil() async {
        let resultAction = await studyMiddleware(
            .arrange,
            .failedToLoadDefinitions,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func refreshAppSettings_returnsNil() async {
        let resultAction = await studyMiddleware(
            .arrange,
            .refreshAppSettings(.arrange),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func addDefinitions_returnsNil() async {
        let resultAction = await studyMiddleware(
            .arrange,
            .addDefinitions([.arrange]),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func failedToSaveDefinitions_returnsNil() async {
        let resultAction = await studyMiddleware(
            .arrange,
            .failedToSaveDefinitions,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
}
