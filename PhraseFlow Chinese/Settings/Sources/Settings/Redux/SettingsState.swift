//
//  SettingsState.swift
//  FlowTale
//
//  Created by iakalann on 06/11/2024.
//

import SwiftUI
import Foundation
import DataStorage
import Moderation

public struct SettingsViewState: Codable, Equatable, Sendable {
    var isShowingModerationDetails: Bool
    var isWritingChapter: Bool
    var moderationResponse: ModerationResponse?
    
    public init(
        isShowingModerationDetails: Bool = false,
        isWritingChapter: Bool = false,
        moderationResponse: ModerationResponse? = nil
    ) {
        self.isShowingModerationDetails = isShowingModerationDetails
        self.isWritingChapter = isWritingChapter
        self.moderationResponse = moderationResponse
    }
    
    enum CodingKeys: String, CodingKey {
        case isShowingModerationDetails
        case isWritingChapter
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isShowingModerationDetails, forKey: .isShowingModerationDetails)
        try container.encode(isWritingChapter, forKey: .isWritingChapter)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isShowingModerationDetails = try container.decode(Bool.self, forKey: .isShowingModerationDetails)
        isWritingChapter = try container.decode(Bool.self, forKey: .isWritingChapter)
        moderationResponse = nil
    }
}

public struct SettingsState: Codable, Equatable, Sendable {
    public var isShowingDefinition: Bool
    public var isShowingEnglish: Bool
    public var isPlayingMusic: Bool
    public var voice: Voice
    public var speechSpeed: SpeechSpeed
    public var difficulty: Difficulty
    public var sourceLanguage: Language = .autoDetect
    public var targetLanguage: Language = .spanish
    public var language: Language = .spanish
    var customPrompt: String
    public var storySetting: StorySetting
    var customPrompts: [String]
    public var shouldPlaySound: Bool
    var isShowingCustomPromptAlert: Bool
    
    // Moderation related properties
    var isShowingModerationFailedAlert: Bool
    var viewState: SettingsViewState
    
    // User limit properties  
    public var usedCharacters: Int
    public var isSubscribedUser: Bool {
        subscriptionLevel != .free
    }
    
    public var remainingCharacters: Int {
        subscriptionLevel.ssmlCharacterLimitPerDay - usedCharacters
    }
    public var timeUntilReset: String?
    public var characterLimitPerDay: Int {
        subscriptionLevel.ssmlCharacterLimitPerDay
    }
    public var subscriptionLevel: SubscriptionLevel
    
    enum CodingKeys: String, CodingKey {
        case isShowingDefinition
        case isShowingEnglish
        case isPlayingMusic
        case voice
        case speechSpeed
        case difficulty
        case sourceLanguage
        case targetLanguage
        case language
        case customPrompt
        case storySetting
        case customPrompts
        case shouldPlaySound
        case isShowingCustomPromptAlert
        case isShowingModerationFailedAlert
        case usedCharacters
        case viewState
        case subscriptionLevel
    }

    public init(
        isShowingDefinition: Bool = true,
        isShowingEnglish: Bool = true,
        isPlayingMusic: Bool = true,
        voice: Voice = .elvira,
        speechSpeed: SpeechSpeed = .normal,
        difficulty: Difficulty = .beginner,
        language: Language = .spanish,
        customPrompt: String = "",
        storySetting: StorySetting = .random,
        customPrompts: [String] = [],
        shouldPlaySound: Bool = true,
        isShowingCustomPromptAlert: Bool = true,
        isShowingModerationFailedAlert: Bool = false,
        viewState: SettingsViewState = SettingsViewState(),
        usedCharacters: Int = 0,
        subscriptionLevel: SubscriptionLevel = .free
    ) {
        self.isShowingDefinition = isShowingDefinition
        self.isShowingEnglish = isShowingEnglish
        self.isPlayingMusic = isPlayingMusic
        self.voice = voice
        self.speechSpeed = speechSpeed
        self.difficulty = difficulty
        self.language = language
        self.customPrompt = customPrompt
        self.customPrompts = customPrompts
        self.storySetting = storySetting
        self.shouldPlaySound = shouldPlaySound
        self.isShowingCustomPromptAlert = isShowingCustomPromptAlert
        self.isShowingModerationFailedAlert = isShowingModerationFailedAlert
        self.viewState = viewState
        self.usedCharacters = usedCharacters
        self.subscriptionLevel = subscriptionLevel
        self.timeUntilReset = nil
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isShowingDefinition = try container.decode(Bool.self, forKey: .isShowingDefinition)
        self.isShowingEnglish = try container.decode(Bool.self, forKey: .isShowingEnglish)
        self.isPlayingMusic = try container.decode(Bool.self, forKey: .isPlayingMusic)
        self.voice = try container.decode(Voice.self, forKey: .voice)
        self.speechSpeed = try container.decode(SpeechSpeed.self, forKey: .speechSpeed)
        self.difficulty = try container.decode(Difficulty.self, forKey: .difficulty)
        self.sourceLanguage = (try? container.decode(Language.self, forKey: .sourceLanguage)) ?? .autoDetect
        self.targetLanguage = (try? container.decode(Language.self, forKey: .targetLanguage)) ?? .spanish
        self.language = try container.decode(Language.self, forKey: .language)
        self.customPrompt = try container.decode(String.self, forKey: .customPrompt)
        self.storySetting = try container.decode(StorySetting.self, forKey: .storySetting)
        self.customPrompts = try container.decode([String].self, forKey: .customPrompts)
        
        self.shouldPlaySound = (try? container.decode(Bool.self, forKey: .shouldPlaySound)) ?? true
        self.isShowingCustomPromptAlert = (try? container.decode(Bool.self, forKey: .isShowingCustomPromptAlert)) ?? false
        self.isShowingModerationFailedAlert = (try? container.decode(Bool.self, forKey: .isShowingModerationFailedAlert)) ?? false
        self.viewState = (try? container.decode(SettingsViewState.self, forKey: .viewState)) ?? SettingsViewState()
        self.subscriptionLevel = (try? container.decode(SubscriptionLevel.self, forKey: .subscriptionLevel)) ?? .free
        self.usedCharacters = (try? container.decode(Int.self, forKey: .usedCharacters)) ?? 0
        self.timeUntilReset = nil
    }
}
