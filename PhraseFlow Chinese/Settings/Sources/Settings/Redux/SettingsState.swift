//
//  SettingsState.swift
//  FlowTale
//
//  Created by iakalann on 06/11/2024.
//

import SwiftUI
import Foundation
import DataStorage

public struct SettingsViewState: Codable, Equatable, Sendable {
    var isShowingModerationDetails: Bool
    var isWritingChapter: Bool
    
    public init(
        isShowingModerationDetails: Bool = false,
        isWritingChapter: Bool = false
    ) {
        self.isShowingModerationDetails = isShowingModerationDetails
        self.isWritingChapter = isWritingChapter
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
    var confirmedCustomPrompt: String
    var customPrompts: [String]
    var shouldPlaySound: Bool
    var isShowingCustomPromptAlert: Bool
    
    // Moderation related properties
    var isShowingModerationFailedAlert: Bool
    var viewState: SettingsViewState
    
    // User limit properties  
    public var remainingCharacters: Int?
    public var isSubscribedUser: Bool {
        subscriptionLevel != .free
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
        case confirmedCustomPrompt
        case customPrompts
        case shouldPlaySound
        case isShowingCustomPromptAlert
        case isShowingModerationFailedAlert
        case remainingCharacters
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
        customPrompt: String = "",
        storySetting: StorySetting = .random,
        customPrompts: [String] = [],
        shouldPlaySound: Bool = true,
        isShowingCustomPromptAlert: Bool = true,
        confirmedCustomPrompt: String = "",
        isShowingModerationFailedAlert: Bool = false,
        viewState: SettingsViewState = SettingsViewState(),
        remainingCharacters: Int? = nil,
        subscriptionLevel: SubscriptionLevel = .free
    ) {
        self.isShowingDefinition = isShowingDefinition
        self.isShowingEnglish = isShowingEnglish
        self.isPlayingMusic = isPlayingMusic
        self.voice = voice
        self.speechSpeed = speechSpeed
        self.difficulty = difficulty
        self.customPrompt = customPrompt
        self.customPrompts = customPrompts
        self.storySetting = storySetting
        self.confirmedCustomPrompt = confirmedCustomPrompt
        self.shouldPlaySound = shouldPlaySound
        self.isShowingCustomPromptAlert = isShowingCustomPromptAlert
        self.isShowingModerationFailedAlert = isShowingModerationFailedAlert
        self.viewState = viewState
        self.remainingCharacters = remainingCharacters
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
        self.confirmedCustomPrompt = try container.decode(String.self, forKey: .confirmedCustomPrompt)
        self.customPrompts = try container.decode([String].self, forKey: .customPrompts)
        
        self.shouldPlaySound = (try? container.decode(Bool.self, forKey: .shouldPlaySound)) ?? true
        self.isShowingCustomPromptAlert = (try? container.decode(Bool.self, forKey: .isShowingCustomPromptAlert)) ?? false
        self.isShowingModerationFailedAlert = (try? container.decode(Bool.self, forKey: .isShowingModerationFailedAlert)) ?? false
        self.viewState = (try? container.decode(SettingsViewState.self, forKey: .viewState)) ?? SettingsViewState()
        self.subscriptionLevel = (try? container.decode(SubscriptionLevel.self, forKey: .subscriptionLevel)) ?? .free
        self.remainingCharacters = try? container.decode(Int.self, forKey: .remainingCharacters)
        self.timeUntilReset = nil
    }
}
