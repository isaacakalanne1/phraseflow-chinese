//
//  SettingsStateTests.swift
//  Settings
//
//  Created by Isaac Akalanne on 21/09/2025.
//

import Testing
import Foundation
import DataStorage
import Moderation
import ModerationMocks
@testable import Settings
@testable import SettingsMocks

class SettingsStateTests {
    
    @Test
    func initializer_setsDefaultValues() {
        let settingsState = SettingsState()
        
        #expect(settingsState.isShowingDefinition == true)
        #expect(settingsState.isShowingEnglish == true)
        #expect(settingsState.isPlayingMusic == true)
        #expect(settingsState.voice == .elvira)
        #expect(settingsState.speechSpeed == .normal)
        #expect(settingsState.difficulty == .beginner)
        #expect(settingsState.language == .spanish)
        #expect(settingsState.sourceLanguage == .autoDetect)
        #expect(settingsState.targetLanguage == .spanish)
        #expect(settingsState.customPrompt == "")
        #expect(settingsState.storySetting == .random)
        #expect(settingsState.customPrompts == [])
        #expect(settingsState.shouldPlaySound == true)
        #expect(settingsState.usedCharacters == 0)
        #expect(settingsState.subscriptionLevel == .free)
        #expect(settingsState.timeUntilReset == nil)
    }
    
    @Test
    func initializer_withCustomValues() {
        let customPrompts = ["Custom prompt 1", "Custom prompt 2"]
        let settingsState = SettingsState(
            isShowingDefinition: false,
            isShowingEnglish: false,
            isPlayingMusic: false,
            voice: .ava,
            speechSpeed: .slow,
            difficulty: .advanced,
            language: .mandarinChinese,
            sourceLanguage: .english,
            targetLanguage: .mandarinChinese,
            customPrompt: "Test prompt",
            storySetting: .customPrompt(""),
            customPrompts: customPrompts,
            shouldPlaySound: false,
            usedCharacters: 1500,
            subscriptionLevel: .level1
        )
        
        #expect(settingsState.isShowingDefinition == false)
        #expect(settingsState.isShowingEnglish == false)
        #expect(settingsState.isPlayingMusic == false)
        #expect(settingsState.voice == .ava)
        #expect(settingsState.speechSpeed == .slow)
        #expect(settingsState.difficulty == .advanced)
        #expect(settingsState.language == .mandarinChinese)
        #expect(settingsState.sourceLanguage == .english)
        #expect(settingsState.targetLanguage == .mandarinChinese)
        #expect(settingsState.customPrompt == "Test prompt")
        #expect(settingsState.storySetting == .customPrompt(""))
        #expect(settingsState.customPrompts == customPrompts)
        #expect(settingsState.shouldPlaySound == false)
        #expect(settingsState.usedCharacters == 1500)
        #expect(settingsState.subscriptionLevel == .level1)
    }
    
    @Test
    func isSubscribedUser_free_false() {
        let settingsState = SettingsState.arrange(subscriptionLevel: .free)
        #expect(settingsState.isSubscribedUser == false)
    }
    
    @Test
    func isSubscribedUser_level1_true() {
        let settingsState = SettingsState.arrange(subscriptionLevel: .level1)
        #expect(settingsState.isSubscribedUser == true)
    }
    
    @Test
    func isSubscribedUser_level2_true() {
        let settingsState = SettingsState.arrange(subscriptionLevel: .level2)
        #expect(settingsState.isSubscribedUser == true)
    }
    
    @Test
    func remainingCharacters_freeSubscription() {
        let usedCharacters = 1000
        let settingsState = SettingsState.arrange(
            usedCharacters: usedCharacters,
            subscriptionLevel: .free
        )
        let expectedRemaining = SubscriptionLevel.free.ssmlCharacterLimitPerDay - usedCharacters
        
        #expect(settingsState.remainingCharacters == expectedRemaining)
    }
    
    @Test
    func remainingCharacters_level1Subscription() {
        let usedCharacters = 5000
        let settingsState = SettingsState.arrange(
            usedCharacters: usedCharacters,
            subscriptionLevel: .level1
        )
        let expectedRemaining = SubscriptionLevel.level1.ssmlCharacterLimitPerDay - usedCharacters
        
        #expect(settingsState.remainingCharacters == expectedRemaining)
    }
    
    @Test
    func remainingCharacters_level2Subscription() {
        let usedCharacters = 10000
        let settingsState = SettingsState.arrange(
            usedCharacters: usedCharacters,
            subscriptionLevel: .level2
        )
        let expectedRemaining = SubscriptionLevel.level2.ssmlCharacterLimitPerDay - usedCharacters
        
        #expect(settingsState.remainingCharacters == expectedRemaining)
    }
    
    @Test
    func characterLimitPerDay_freeSubscription() {
        let settingsState = SettingsState.arrange(subscriptionLevel: .free)
        #expect(settingsState.characterLimitPerDay == SubscriptionLevel.free.ssmlCharacterLimitPerDay)
    }
    
    @Test
    func characterLimitPerDay_level1Subscription() {
        let settingsState = SettingsState.arrange(subscriptionLevel: .level1)
        #expect(settingsState.characterLimitPerDay == SubscriptionLevel.level1.ssmlCharacterLimitPerDay)
    }
    
    @Test
    func characterLimitPerDay_level2Subscription() {
        let settingsState = SettingsState.arrange(subscriptionLevel: .level2)
        #expect(settingsState.characterLimitPerDay == SubscriptionLevel.level2.ssmlCharacterLimitPerDay)
    }
    
    @Test
    func equatable_sameStates() {
        let state1 = SettingsState.arrange(language: .english, usedCharacters: 500)
        let state2 = SettingsState.arrange(language: .english, usedCharacters: 500)
        
        #expect(state1 == state2)
    }
    
    @Test
    func equatable_differentLanguages() {
        let state1 = SettingsState.arrange(language: .english)
        let state2 = SettingsState.arrange(language: .spanish)
        
        #expect(state1 != state2)
    }
    
    @Test
    func equatable_differentUsedCharacters() {
        let state1 = SettingsState.arrange(usedCharacters: 500)
        let state2 = SettingsState.arrange(usedCharacters: 1000)
        
        #expect(state1 != state2)
    }
    
    @Test
    func equatable_differentSubscriptionLevels() {
        let state1 = SettingsState.arrange(subscriptionLevel: .free)
        let state2 = SettingsState.arrange(subscriptionLevel: .level1)
        
        #expect(state1 != state2)
    }
    
    @Test
    func codable_encodeAndDecode() throws {
        let originalState = SettingsState.arrange(
            isShowingDefinition: false,
            voice: .ava,
            language: .mandarinChinese,
            customPrompts: ["Prompt 1", "Prompt 2"],
            usedCharacters: 2500,
            subscriptionLevel: .level2
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalState)
        
        let decoder = JSONDecoder()
        let decodedState = try decoder.decode(SettingsState.self, from: data)
        
        #expect(decodedState.isShowingDefinition == originalState.isShowingDefinition)
        #expect(decodedState.voice == originalState.voice)
        #expect(decodedState.language == originalState.language)
        #expect(decodedState.customPrompts == originalState.customPrompts)
        #expect(decodedState.usedCharacters == originalState.usedCharacters)
        #expect(decodedState.subscriptionLevel == originalState.subscriptionLevel)
        #expect(decodedState.timeUntilReset == nil)
    }
}

