//
//  FastChineseMiddleware.swift
//  FastChinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import ReduxKit
import AVKit
import StoreKit

typealias FastChineseMiddlewareType = Middleware<FastChineseState, FastChineseAction, FastChineseEnvironmentProtocol>
let fastChineseMiddleware: FastChineseMiddlewareType = { state, action, environment in
    switch action {
    case .onContinuedStory(let story):
        if let chapter = story.chapters[safe: story.currentChapterIndex] {
            return .synthesizeAudio(chapter, voice: state.settingsState.voice, isForced: true)
        }
        return .saveStoryAndSettings(story)
    case .continueStory(let story):
        do {
            let story = try await environment.generateStory(story: story, deviceLanguage: state.deviceLanguage)
            return .onContinuedStory(story)
        } catch {
            return .failedToContinueStory
        }
    case .loadStories:
        do {
            let stories = try environment.loadStories().sorted(by: { $0.lastUpdated > $1.lastUpdated })
            return .onLoadedStories(stories)
        } catch {
            return .failedToLoadStories
        }
    case .loadDefinitions:
        do {
            let definitions = try environment.loadDefinitions()
            return .onLoadedDefinitions(definitions)
        } catch {
            return .failedToLoadDefinitions
        }
    case .saveStory(let story):
        do {
            try environment.saveStory(story)
            return .loadStories
        } catch {
            return .failedToSaveStory
        }
    case .deleteStory(let story):
        do {
            try environment.unsaveStory(story)
            return .onDeletedStory
        } catch {
            return .failedToDeleteStory
        }
    case .onDeletedStory:
        return .loadStories
    case .synthesizeAudio(let chapter, let voice, let isForced):
        if chapter.audioData != nil && chapter.audioVoice == state.settingsState.voice && chapter.audioSpeed == state.settingsState.speechSpeed && !isForced {
            return .playAudio(time: nil)
        }
        do {
            let result = try await environment.synthesizeSpeech(for: chapter,
                                                                voice: voice,
                                                                speechSpeed: state.settingsState.speechSpeed,
                                                                language: state.storyState.currentStory?.language)
            return .onSynthesizedAudio(result)
        } catch {
            return .failedToSynthesizeAudio
        }
    case .onSynthesizedAudio(let result):
        if let story = state.storyState.currentStory {
            return .saveStory(story)
        }
        return nil
    case .playAudio(let timestamp):
        if let timestamp {
            let myTime = CMTime(seconds: timestamp, preferredTimescale: 60000)
            await state.audioState.audioPlayer.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
        }
        state.audioState.audioPlayer.currentItem?.forwardPlaybackEndTime = CMTime(seconds: .infinity, preferredTimescale: 1)
        state.audioState.audioPlayer.play()
        return nil
    case .playWord(let word):
        let myTime = CMTime(seconds: word.time, preferredTimescale: 60000)
        await state.audioState.audioPlayer.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
        state.audioState.audioPlayer.currentItem?.forwardPlaybackEndTime = CMTime(seconds: word.time + word.duration, preferredTimescale: 60000)
        state.audioState.audioPlayer.play()
        return nil
    case .pauseAudio,
            .stopAudio,
            .finishedPlayingWord:
        state.audioState.audioPlayer.pause()
        return nil
    case .defineCharacter(let timeStampData, let shouldForce):
        do {
            guard let sentence = state.storyState.currentSentence else {
                return .failedToDefineCharacter
            }
            
            if let definition = state.definitionState.definition(of: timeStampData.word, in: sentence),
               !shouldForce {
                return .onDefinedCharacter(definition)
            }
            guard let story = state.storyState.currentStory else {
                return .failedToDefineCharacter
            }
            let fetchedDefinition = try await environment.fetchDefinition(of: timeStampData.word,
                                                                          withinContextOf: sentence,
                                                                          story: story,
                                                                          settings: state.settingsState,
                                                                          deviceLanguage: state.deviceLanguage)
            return .onDefinedCharacter(fetchedDefinition)
        } catch {
            return .failedToDefineCharacter
        }
    case .onDefinedCharacter:
        return .saveDefinitions
    case .saveDefinitions:
        do {
            try environment.saveDefinitions(state.definitionState.definitions)
            return .onSavedDefinitions
        } catch {
            return .failedToSaveDefinitions
        }
    case .onSavedDefinitions:
        return .refreshDefinitionView
    case .selectChapter:
        return .onSelectedChapter
    case .onSelectedChapter:
        if let story = state.storyState.currentStory {
            return .saveStoryAndSettings(story)
        }
        return nil
    case .saveStoryAndSettings(let story):
        do {
            try environment.saveStory(story)
            try environment.saveAppSettings(state.settingsState)
            return .onSavedStoryAndSettings
        } catch {
            return .failedToSaveStoryAndSettings
        }
    case .onSavedStoryAndSettings:
        return .loadStories
    case .selectWord(let word):
        if state.audioState.isPlayingAudio {
            let myTime = CMTime(seconds: word.time, preferredTimescale: 60000)
            await state.audioState.audioPlayer.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
            state.audioState.audioPlayer.currentItem?.forwardPlaybackEndTime = CMTime(seconds: .infinity, preferredTimescale: 60000)
            state.audioState.audioPlayer.play()
            return nil
        } else {
            return .playWord(word)
        }
    case .goToNextChapter:
        if let story = state.storyState.currentStory {
            return .saveStory(story)
        }
        return nil
    case .updatePlayTime:
        let time = state.audioState.audioPlayer.currentTime().seconds
        if let lastWordTime = state.storyState.currentChapter?.timestampData.last?.time,
           time > lastWordTime {
            return .pauseAudio
        } else {
            return nil
        }
    case .selectVoice,
            .updateSpeechSpeed,
            .updateShowDefinition,
            .updateShowEnglish,
            .updateLanguage,
            .updateDifficulty:
        return .saveAppSettings
    case .saveAppSettings:
        do {
            try environment.saveAppSettings(state.settingsState)
            return nil
        } catch {
            return .failedToSaveAppSettings
        }
    case .loadAppSettings:
        do {
            let settings = try environment.loadAppSettings()
            return .onLoadedAppSettings(settings)
        } catch {
            return .failedToLoadAppSettings
        }
    case .updateSentenceIndex:
        return .refreshTranslationView
    case .fetchSubscriptions:
        do {
            let subscriptions = try await environment.getProducts()
            return .onFetchedSubscriptions(subscriptions)
        } catch {
            return .failedToFetchSubscriptions
        }
    case .purchaseSubscription(let product):
        do {
            try await environment.purchase(product)
        } catch {
            return .failedToPurchaseSubscription
        }
        return .onPurchasedSubscription
    case .onPurchasedSubscription:
        return .getCurrentEntitlements
    case .restoreSubscriptions:
        do {
            try await AppStore.sync()
        } catch {
            return .failedToRestoreSubscriptions
        }
        return .onRestoredSubscriptions
    case .getCurrentEntitlements:
        var entitlements: [VerificationResult<Transaction>] = []
        for await result in Transaction.currentEntitlements {
            entitlements.append(result)
        }
        return .updatePurchasedProducts(entitlements)
    case .observeTransactionUpdates:
        var entitlements: [VerificationResult<Transaction>] = []
        for await result in Transaction.updates {
            entitlements.append(result)
        }
        return .updatePurchasedProducts(entitlements)
    case .failedToLoadStories,
            .failedToSaveStory,
            .failedToDefineCharacter,
            .onPlayedAudio,
            .failedToSynthesizeAudio,
            .updateShowingSettings,
            .updateShowingStoryListView,
            .failedToContinueStory,
            .refreshChapterView,
            .refreshDefinitionView,
            .failedToDeleteStory,
            .failedToSaveAppSettings,
            .onLoadedAppSettings,
            .failedToLoadAppSettings,
            .refreshTranslationView,
            .onLoadedStories,
            .onLoadedDefinitions,
            .failedToLoadDefinitions,
            .failedToSaveDefinitions,
            .failedToSaveStoryAndSettings,
            .refreshStoryListView,
            .onFetchedSubscriptions,
            .failedToFetchSubscriptions,
            .updatePurchasedProducts,
            .failedToPurchaseSubscription,
            .onRestoredSubscriptions,
            .failedToRestoreSubscriptions,
            .setSubscriptionSheetShowing:
        return nil
    }
}
