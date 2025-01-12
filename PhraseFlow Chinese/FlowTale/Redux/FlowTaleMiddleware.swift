//
//  FlowTaleMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import ReduxKit
import AVKit
import StoreKit

typealias FlowTaleMiddlewareType = Middleware<FlowTaleState, FlowTaleAction, FlowTaleEnvironmentProtocol>
let flowTaleMiddleware: FlowTaleMiddlewareType = { state, action, environment in
    switch action {
    case .translateStory(let story, let storyString):
        do {
            let story = try await environment.translateStory(story: story,
                                                             storyString: storyString,
                                                             deviceLanguage: state.deviceLanguage)
            return .onTranslatedStory(story: story)
        } catch {
            return .failedToTranslateStory(story: story, storyString: storyString)
        }
    case .onTranslatedStory(let story):
        if story.imageData == nil,
           let passage = story.chapters.first?.passage {
             return .generateImage(passage: passage, story)
        } else if let chapter = story.chapters[safe: story.currentChapterIndex] {
            return .synthesizeAudio(chapter,
                                    story: story,
                                    voice: state.settingsState.voice,
                                    isForced: true)
        }
        return .saveStoryAndSettings(story)
    case .continueStory(let story):
        do {
            let storyString = try await environment.generateStory(story: story)
            return .translateStory(story: story, storyString: storyString)
        } catch {
            return .failedToContinueStory(story: story)
        }
    case .failedToContinueStory(let story),
            .failedToTranslateStory(let story, _),
            .failedToGenerateImage(let story):
        return .showSnackBar(.failedToWriteChapter(story))
    case .showSnackBar(let type):
        state.appAudioState.audioPlayer.play()
        if let duration = type.showDuration {
            try? await Task.sleep(for: .seconds(duration))
            return .hideSnackbar
        }
        return nil
    case .loadStories(let isAppLaunch):
        do {
            let stories = try environment.loadStories().sorted(by: { $0.lastUpdated > $1.lastUpdated })
            return .onLoadedStories(stories, isAppLaunch: isAppLaunch)
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
    case .deleteStory(let story):
        do {
            try environment.unsaveStory(story)
            return .onDeletedStory
        } catch {
            return .failedToDeleteStory
        }
    case .onDeletedStory:
        return .loadStories(isAppLaunch: false)
    case .synthesizeAudio(let chapter, let story, let voice, let isForced):
        if chapter.audio.data != nil,
           chapter.audioVoice == state.settingsState.voice,
           chapter.audioSpeed == state.settingsState.speechSpeed,
           !isForced {
            return .playAudio(time: nil)
        }
        do {
            let result = try await environment.synthesizeSpeech(for: chapter,
                                                                story: story,
                                                                voice: voice,
                                                                speechSpeed: state.settingsState.speechSpeed,
                                                                language: state.storyState.currentStory?.language)
            return .onSynthesizedAudio(result, story, isForced: isForced)
        } catch {
            return .failedToSynthesizeAudio
        }
    case .onSynthesizedAudio(let result, let story, let isForced):
        return .saveStoryAndSettings(story)
    case .playAudio(let timestamp):
        if let timestamp {
            let myTime = CMTime(seconds: timestamp, preferredTimescale: 60000)
            await state.audioState.audioPlayer.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
        }
        state.audioState.audioPlayer.currentItem?.forwardPlaybackEndTime = CMTime(seconds: .infinity, preferredTimescale: 1)
        state.audioState.audioPlayer.play()
        if let story = state.storyState.currentStory {
            return .saveStoryAndSettings(story)
        }
        return nil
    case .playWord(let word, let story):
        let myTime = CMTime(seconds: word.time, preferredTimescale: 60000)
        await state.audioState.audioPlayer.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
        state.audioState.audioPlayer.currentItem?.forwardPlaybackEndTime = CMTime(seconds: word.time + word.duration, preferredTimescale: 60000)
        state.audioState.audioPlayer.play()
        if let story = state.storyState.currentStory {
            return .saveStoryAndSettings(story)
        }
        return nil
    case .playStudyWord(let definition):
        let myTime = CMTime(seconds: definition.timestampData.time, preferredTimescale: 60000)
        await state.studyState.audioPlayer.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
        state.studyState.audioPlayer.currentItem?.forwardPlaybackEndTime = CMTime(seconds: definition.timestampData.time + definition.timestampData.duration, preferredTimescale: 60000)
        state.studyState.audioPlayer.play()
        return nil
    case .playSound:
        state.appAudioState.audioPlayer.play()
        return nil
    case .playMusic:
        state.musicAudioState.audioPlayer.play()
        if let story = state.storyState.currentStory {
            return .saveStoryAndSettings(story)
        }
        return nil
    case .stopMusic:
        state.musicAudioState.audioPlayer.stop()
        if let story = state.storyState.currentStory {
            return .saveStoryAndSettings(story)
        }
        return nil
    case .pauseAudio:
        state.audioState.audioPlayer.pause()
        if let story = state.storyState.currentStory {
            return .saveStoryAndSettings(story)
        }
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
            let fetchedDefinition = try await environment.fetchDefinition(of: timeStampData,
                                                                          withinContextOf: sentence,
                                                                          story: story,
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
    case .saveStoryAndSettings(var story):
        story.chapters = story.chapters.enumerated().map({ (index, element) in
            var newChapter = element
            let isLastChapter = index >= story.chapters.count - 1
            if !isLastChapter {
//                newChapter.audioData = nil // TODO: Update save stories logic to only save individual chapter rather than all chapters at once
            }
            return newChapter
        })
        do {
            try environment.saveStory(story)
            try environment.saveAppSettings(state.settingsState)
            return .onSavedStoryAndSettings
        } catch {
            return .failedToSaveStoryAndSettings
        }
    case .onSavedStoryAndSettings:
        return .loadStories(isAppLaunch: false)
    case .selectWord(let word):
        if state.audioState.isPlayingAudio {
            let myTime = CMTime(seconds: word.time, preferredTimescale: 60000)
            await state.audioState.audioPlayer.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
            state.audioState.audioPlayer.currentItem?.forwardPlaybackEndTime = CMTime(seconds: .infinity, preferredTimescale: 60000)
            state.audioState.audioPlayer.play()
        } else {
            return .playWord(word, story: state.storyState.currentStory)
        }
        if let story = state.storyState.currentStory {
            return .saveStoryAndSettings(story)
        }
        return nil
    case .goToNextChapter:
        if let story = state.storyState.currentStory {
            return .saveStoryAndSettings(story)
        }
        return nil
    case .updatePlayTime:
        let time = state.audioState.audioPlayer.currentTime().seconds
        if let lastWordTime = state.storyState.currentChapter?.audio.timestamps.last?.time,
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
        return .updatePurchasedProducts(entitlements, isOnLaunch: true)
    case .observeTransactionUpdates:
        var entitlements: [VerificationResult<Transaction>] = []
        for await result in Transaction.updates {
            entitlements.append(result)
        }
        return .updatePurchasedProducts(entitlements, isOnLaunch: false)
    case .updatePurchasedProducts(let entitlements, let isOnLaunch):
        for result in entitlements {
            switch result {
            case .unverified(let transaction, _),
                    .verified(let transaction):
                if transaction.revocationDate == nil && !isOnLaunch {
                    return .showSnackBar(.subscribed)
                } else {
                    return nil
                }
            }
        }
        return nil
    case .generateImage(let passage, let story):
        do {
            let data = try await environment.generateImage(with: passage)
            return .onGeneratedImage(data, story)
        } catch {
            return .failedToGenerateImage(story)
        }
    case .onGeneratedImage(let data, var story):
        story.imageData = data
        if let chapter = story.chapters[safe: story.currentChapterIndex] {
            return .synthesizeAudio(chapter,
                                    story: story,
                                    voice: state.settingsState.voice,
                                    isForced: true)
        }
        return .saveStoryAndSettings(story)
    case .updateStudiedWord:
        return .saveDefinitions
    case .onLoadedAppSettings:
        if state.settingsState.isPlayingMusic {
            return .playMusic(.whispersOfAnOpenBook)
        }
        return nil
    case .updateStorySetting(let setting):
        switch setting {
        case .random:
            return nil
        case .customPrompt(let prompt):
            let isNewPrompt = !state.settingsState.customPrompts.contains(prompt)
            if isNewPrompt {
                return .moderateText(prompt)
            } else {
                return nil
            }
        }
    case .moderateText(let prompt):
        do {
            let response = try await environment.moderateText(prompt)
            return .onModeratedText(response, prompt)
        } catch {
            return .failedToModerateText
        }
    case .onModeratedText(let response, let prompt):
        return response.didPassModeration ? .passedModeration(prompt) : .didNotPassModeration
    case .passedModeration:
        try? environment.saveAppSettings(state.settingsState)
        return .showSnackBar(.passedModeration)
    case .didNotPassModeration:
        return .showSnackBar(.didNotPassModeration)
    case .failedToModerateText:
        return .showSnackBar(.didNotPassModeration)
    case .selectTab:
        return .playSound(.actionButtonPress)
    case .onLoadedStories(_, let isAppLaunch):
        return isAppLaunch ? .showSnackBar(.welcomeBack) : nil
    case .deleteCustomPrompt:
        return .showSnackBar(.deletedCustomStory)
    case .failedToLoadStories,
            .failedToSaveStory,
            .failedToDefineCharacter,
            .onPlayedAudio,
            .failedToSynthesizeAudio,
            .updateShowingSettings,
            .updateShowingStoryListView,
            .refreshChapterView,
            .refreshDefinitionView,
            .failedToDeleteStory,
            .failedToSaveAppSettings,
            .failedToLoadAppSettings,
            .refreshTranslationView,
            .onLoadedDefinitions,
            .failedToLoadDefinitions,
            .failedToSaveDefinitions,
            .failedToSaveStoryAndSettings,
            .refreshStoryListView,
            .onFetchedSubscriptions,
            .failedToFetchSubscriptions,
            .failedToPurchaseSubscription,
            .onRestoredSubscriptions,
            .failedToRestoreSubscriptions,
            .setSubscriptionSheetShowing,
            .updateShowingStudyView,
            .updateShowingDefinitionsChartView,
            .updateAutoScrollEnabled,
            .hideSnackbar,
            .onSelectedChapter,
            .updateCustomPrompt,
            .updateIsShowingCustomPromptAlert:
        return nil
    }
}
