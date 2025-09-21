//
//  StudyStateTests.swift
//  Study
//
//  Created by Isaac Akalanne on 21/09/2025.
//

import Testing
import Foundation
import AVKit
import Settings
import SettingsMocks
import TextGeneration
import TextGenerationMocks
@testable import Study
@testable import StudyMocks

class StudyStateTests {
    
    @Test
    func initializer_setsDefaultValues() {
        let studyState = StudyState()
        
        #expect(studyState.audioPlayer != nil)
        #expect(studyState.sentenceAudioPlayer != nil)
        #expect(studyState.definitions.isEmpty)
        #expect(studyState.displayStatus == .wordShown)
        #expect(studyState.settings == SettingsState())
    }
    
    @Test
    func initializer_withCustomValues() {
        let audioPlayer = AVPlayer()
        let sentenceAudioPlayer = AVPlayer()
        let definitions = [Definition.arrange, Definition.arrange]
        let displayStatus = StudyDisplayStatus.allShown
        let settings = SettingsState.arrange(language: .mandarinChinese)
        
        let studyState = StudyState(
            audioPlayer: audioPlayer,
            sentenceAudioPlayer: sentenceAudioPlayer,
            definitions: definitions,
            displayStatus: displayStatus,
            settings: settings
        )
        
        #expect(studyState.audioPlayer === audioPlayer)
        #expect(studyState.sentenceAudioPlayer === sentenceAudioPlayer)
        #expect(studyState.definitions == definitions)
        #expect(studyState.displayStatus == displayStatus)
        #expect(studyState.settings == settings)
    }
    
    @Test
    func studyDefinitions_emptyDefinitions_returnsEmptyArray() {
        let studyState = StudyState.arrange(definitions: [])
        
        let result = studyState.studyDefinitions(language: .english)
        
        #expect(result.isEmpty)
    }
    
    @Test
    func studyDefinitions_filtersCorrectLanguage() {
        let englishDefinition = Definition.arrange(
            timestampData: .arrange(word: "hello"),
            language: .english,
            hasBeenSeen: true
        )
        let spanishDefinition = Definition.arrange(
            timestampData: .arrange(word: "hola"),
            language: .spanish,
            hasBeenSeen: true
        )
        let definitions = [englishDefinition, spanishDefinition]
        let studyState = StudyState.arrange(definitions: definitions)
        
        let englishResults = studyState.studyDefinitions(language: .english)
        let spanishResults = studyState.studyDefinitions(language: .spanish)
        
        #expect(englishResults.count == 1)
        #expect(englishResults[0].language == .english)
        #expect(spanishResults.count == 1)
        #expect(spanishResults[0].language == .spanish)
    }
    
    @Test
    func studyDefinitions_filtersHasBeenSeen() {
        let seenDefinition = Definition.arrange(
            timestampData: .arrange(word: "hello"),
            language: .english,
            hasBeenSeen: true
        )
        let unseenDefinition = Definition.arrange(
            timestampData: .arrange(word: "world"),
            language: .english,
            hasBeenSeen: false
        )
        let definitions = [seenDefinition, unseenDefinition]
        let studyState = StudyState.arrange(definitions: definitions)
        
        let results = studyState.studyDefinitions(language: .english)
        
        #expect(results.count == 1)
        #expect(results[0].hasBeenSeen == true)
    }
    
    @Test
    func studyDefinitions_filtersEmptyWords() {
        let validDefinition = Definition.arrange(
            timestampData: .arrange(word: "hello"),
            language: .english,
            hasBeenSeen: true
        )
        let emptyWordDefinition = Definition.arrange(
            timestampData: .arrange(word: ""),
            language: .english,
            hasBeenSeen: true
        )
        let punctuationOnlyDefinition = Definition.arrange(
            timestampData: .arrange(word: ".,!?"),
            language: .english,
            hasBeenSeen: true
        )
        let whiteSpaceOnlyDefinition = Definition.arrange(
            timestampData: .arrange(word: "   "),
            language: .english,
            hasBeenSeen: true
        )
        let definitions = [validDefinition, emptyWordDefinition, punctuationOnlyDefinition, whiteSpaceOnlyDefinition]
        let studyState = StudyState.arrange(definitions: definitions)
        
        let results = studyState.studyDefinitions(language: .english)
        
        #expect(results.count == 1)
        #expect(results[0].timestampData.word == "hello")
    }
    
    @Test
    func studyDefinitions_sortsByCreationDateDescending() {
        let oldDate = Date().addingTimeInterval(-100)
        let recentDate = Date().addingTimeInterval(-50)
        let latestDate = Date()
        
        let oldDefinition = Definition.arrange(
            creationDate: oldDate,
            timestampData: .arrange(word: "old"),
            language: .english,
            hasBeenSeen: true
        )
        let recentDefinition = Definition.arrange(
            creationDate: recentDate,
            timestampData: .arrange(word: "recent"),
            language: .english,
            hasBeenSeen: true
        )
        let latestDefinition = Definition.arrange(
            creationDate: latestDate,
            timestampData: .arrange(word: "latest"),
            language: .english,
            hasBeenSeen: true
        )
        
        let definitions = [oldDefinition, latestDefinition, recentDefinition]
        let studyState = StudyState.arrange(definitions: definitions)
        
        let results = studyState.studyDefinitions(language: .english)
        
        #expect(results.count == 3)
        #expect(results[0].timestampData.word == "latest")
        #expect(results[1].timestampData.word == "recent")
        #expect(results[2].timestampData.word == "old")
    }
    
    @Test
    func studyDefinitions_nilLanguage_returnsEmptyArray() {
        let definition = Definition.arrange(
            timestampData: .arrange(word: "hello"),
            language: .english,
            hasBeenSeen: true
        )
        let studyState = StudyState.arrange(definitions: [definition])
        
        let results = studyState.studyDefinitions(language: nil)
        
        #expect(results.isEmpty)
    }
    
    @Test
    func dailyCreationCount_emptyDefinitions_returnsZero() {
        let studyState = StudyState.arrange(definitions: [])
        
        let count = studyState.dailyCreationCount(from: [])
        
        #expect(count == 0)
    }
    
    @Test
    func dailyCreationCount_todayDefinitions_returnsCorrectCount() {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today
        
        let todayDefinition1 = Definition.arrange(creationDate: today)
        let todayDefinition2 = Definition.arrange(creationDate: today)
        let yesterdayDefinition = Definition.arrange(creationDate: yesterday)
        
        let definitions = [todayDefinition1, todayDefinition2, yesterdayDefinition]
        let studyState = StudyState.arrange()
        
        let count = studyState.dailyCreationCount(from: definitions)
        
        #expect(count == 2)
    }
    
    @Test
    func dailyStudiedCount_emptyDefinitions_returnsZero() {
        let studyState = StudyState.arrange(definitions: [])
        
        let count = studyState.dailyStudiedCount(from: [])
        
        #expect(count == 0)
    }
    
    @Test
    func dailyStudiedCount_todayStudiedDefinitions_returnsCorrectCount() {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today
        
        let definition1 = Definition.arrange(studiedDates: [today])
        let definition2 = Definition.arrange(studiedDates: [today, yesterday])
        let definition3 = Definition.arrange(studiedDates: [yesterday])
        let definition4 = Definition.arrange(studiedDates: [])
        
        let definitions = [definition1, definition2, definition3, definition4]
        let studyState = StudyState.arrange()
        
        let count = studyState.dailyStudiedCount(from: definitions)
        
        #expect(count == 2)
    }
    
    @Test
    func dailyStudiedCount_multipleStudyDatesForSameDefinition_countsOnce() {
        let today = Date()
        let todayMorning = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: today) ?? today
        let todayEvening = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: today) ?? today
        
        let definition = Definition.arrange(studiedDates: [todayMorning, todayEvening])
        let studyState = StudyState.arrange()
        
        let count = studyState.dailyStudiedCount(from: [definition])
        
        #expect(count == 1)
    }
    
    @Test
    func dailyCreationAndStudyCumulative_emptyDefinitions_returnsEmptyArray() {
        let studyState = StudyState.arrange()
        
        let stats = studyState.dailyCreationAndStudyCumulative(from: [])
        
        #expect(stats.isEmpty)
    }
    
    @Test
    func dailyCreationAndStudyCumulative_excludesTodayData() {
        let today = Date()
        let todayDefinition = Definition.arrange(
            creationDate: today,
            studiedDates: [today]
        )
        let studyState = StudyState.arrange()
        
        let stats = studyState.dailyCreationAndStudyCumulative(from: [todayDefinition])
        
        #expect(stats.isEmpty)
    }
    
    @Test
    func equatable_sameStates() {
        let audioPlayer = AVPlayer()
        let sentenceAudioPlayer = AVPlayer()
        let definitions = [Definition.arrange]
        let displayStatus = StudyDisplayStatus.pronounciationShown
        let settings = SettingsState.arrange(language: .english)
        
        let state1 = StudyState.arrange(
            audioPlayer: audioPlayer,
            sentenceAudioPlayer: sentenceAudioPlayer,
            definitions: definitions,
            displayStatus: displayStatus,
            settings: settings
        )
        
        let state2 = StudyState.arrange(
            audioPlayer: audioPlayer,
            sentenceAudioPlayer: sentenceAudioPlayer,
            definitions: definitions,
            displayStatus: displayStatus,
            settings: settings
        )
        
        #expect(state1 == state2)
    }
    
    @Test
    func equatable_differentAudioPlayer() {
        let audioPlayer1 = AVPlayer()
        let audioPlayer2 = AVPlayer()
        
        let state1 = StudyState.arrange(audioPlayer: audioPlayer1)
        let state2 = StudyState.arrange(audioPlayer: audioPlayer2)
        
        #expect(state1 != state2)
    }
    
    @Test
    func equatable_differentSentenceAudioPlayer() {
        let sentenceAudioPlayer1 = AVPlayer()
        let sentenceAudioPlayer2 = AVPlayer()
        
        let state1 = StudyState.arrange(sentenceAudioPlayer: sentenceAudioPlayer1)
        let state2 = StudyState.arrange(sentenceAudioPlayer: sentenceAudioPlayer2)
        
        #expect(state1 != state2)
    }
    
    @Test
    func equatable_differentDefinitions() {
        let definitions1 = [Definition.arrange]
        let definitions2 = [Definition.arrange, Definition.arrange]
        
        let state1 = StudyState.arrange(definitions: definitions1)
        let state2 = StudyState.arrange(definitions: definitions2)
        
        #expect(state1 != state2)
    }
    
    @Test
    func equatable_differentDisplayStatus() {
        let state1 = StudyState.arrange(displayStatus: .wordShown)
        let state2 = StudyState.arrange(displayStatus: .allShown)
        
        #expect(state1 != state2)
    }
    
    @Test
    func equatable_differentSettings() {
        let settings1 = SettingsState.arrange(language: .english)
        let settings2 = SettingsState.arrange(language: .spanish)
        
        let state1 = StudyState.arrange(settings: settings1)
        let state2 = StudyState.arrange(settings: settings2)
        
        #expect(state1 != state2)
    }
}

