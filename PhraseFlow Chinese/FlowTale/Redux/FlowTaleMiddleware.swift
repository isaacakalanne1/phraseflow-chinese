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
            return .failedToTranslateStory
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
    case .checkFreeTrialLimit:
        do {
            // 1) Enforce usage limit:
            // If user is free, subscription = nil => total limit (4).
            // If user has subscription => daily limit based on level.
            try environment.enforceChapterCreationLimit(subscription: state.subscriptionState.currentSubscription)

            return nil
        } catch FlowTaleDataStoreError.freeUserChapterLimitReached {
            // If the free user has created all 4 chapters, show an error or prompt to upgrade
            return .hasReachedFreeTrialLimit
        } catch FlowTaleDataStoreError.chapterCreationLimitReached(let nextAvailable) {
            // If the subscribed user hit the daily limit
            return .hasReachedDailyLimit
        } catch {
            // Some other error from generateStory
            return nil
        }

    case .createChapter(let type):

        do {
            try environment.enforceChapterCreationLimit(subscription: state.subscriptionState.currentSubscription)
            switch type {
            case .newStory:
                let story = state.createNewStory()
                let storyString = try await environment.generateStory(story: story)
                return .translateStory(story: story, storyString: storyString)
            case .existingStory(let st):
                let story = st
                let storyString = try await environment.generateStory(story: story)
                return .translateStory(story: story, storyString: storyString)
            }
        } catch FlowTaleDataStoreError.freeUserChapterLimitReached {
            return .setSubscriptionSheetShowing(true)
        } catch FlowTaleDataStoreError.chapterCreationLimitReached(let nextAvailable) {
            return .onDailyChapterLimitReached(nextAvailable: nextAvailable)
        } catch {
            return .failedToCreateChapter
        }

    case .onDailyChapterLimitReached(let nextAvailable):
        return .showSnackBar(.dailyChapterLimitReached(nextAvailable: nextAvailable))

    case .failedToCreateChapter,
            .failedToTranslateStory,
            .failedToGenerateImage:
        return .showSnackBar(.failedToWriteChapter)
    case .showSnackBar(let type):
        state.appAudioState.audioPlayer.play()
        if let duration = type.showDuration {
            try? await Task.sleep(for: .seconds(duration))
            return .hideSnackbar
        }
        return nil
    case .loadStories(let isAppLaunch):
        do {
            var stories = try environment.loadAllStories()
                .sorted(by: { $0.lastUpdated > $1.lastUpdated })
            // No call to loadAllChapters(for:) here — we skip that
            return .onLoadedStories(stories, isAppLaunch: isAppLaunch)
        } catch {
            return .failedToLoadStories
        }
    case .loadChapters(let story, let isAppLaunch):
        do {
            // 1) Load the chapters for just this one story
            let chapters = try environment.loadAllChapters(for: story.id)

            // 2) Dispatch success with the loaded chapters
            return .onLoadedChapters(story, chapters, isAppLaunch: isAppLaunch)
        } catch {
            // 3) Dispatch failure
            return .failedToLoadChapters
        }
    case .loadDefinitions:
        do {
            let definitions = try environment.loadDefinitions()
            return .onLoadedDefinitions(definitions)
        } catch {
            return .failedToLoadDefinitions
        }
    case .loadDefinitionsForStory(let storyId):
        do {
            let definitions = try environment.loadDefinitions(for: storyId)
            return .onLoadedDefinitions(definitions)
        } catch {
            return .failedToLoadDefinitions
        }
    case .deleteStory(let story):
        do {
            // Delete definitions for this story
            try environment.deleteDefinitions(for: story.id)
            
            // Delete the story and its chapters
            try environment.unsaveStory(story)
            
            // Cleanup any orphaned definition files
            try environment.cleanupOrphanedDefinitionFiles()
            
            return .onDeletedStory
        } catch {
            return .failedToDeleteStory
        }
    case .onDeletedStory:
        return .loadStories(isAppLaunch: false)
    case .synthesizeAudio(let chapter, let story, let voice, let isForced):
        if chapter.audioVoice == state.settingsState.voice,
           chapter.audioSpeed == state.settingsState.speechSpeed,
           !isForced {
            return .playAudio(time: nil)
        }
        do {
            let result = try await environment.synthesizeSpeech(for: chapter,
                                                                story: story,
                                                                voice: voice,
                                                                language: story.language)
            return .onSynthesizedAudio(result, story, isForced: isForced)
        } catch {
            return .failedToSynthesizeAudio
        }
    case .onSynthesizedAudio:
        if let story = state.storyState.currentStory {
            return .saveStoryAndSettings(story)
        }
        return nil
    case .playAudio(let timestamp):
        if let timestamp {
            let myTime = CMTime(seconds: timestamp, preferredTimescale: 60000)
            await state.audioState.audioPlayer.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
        } else {
            let time = state.audioState.audioPlayer.currentTime().seconds
            if let lastWordTime = state.storyState.currentChapter?.audio.timestamps.last?.time,
               time > lastWordTime {
                await state.audioState.audioPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 60000), toleranceBefore: .zero, toleranceAfter: .zero)
            }
        }
        state.audioState.audioPlayer.currentItem?.forwardPlaybackEndTime = CMTime(seconds: .infinity, preferredTimescale: 1)
        state.audioState.audioPlayer.playImmediately(atRate: state.settingsState.speechSpeed.playRate)
        if let story = state.storyState.currentStory {
            return .saveStoryAndSettings(story)
        }
        return nil
    case .playWord(let word, let story):
        let myTime = CMTime(seconds: word.time, preferredTimescale: 60000)
        await state.audioState.audioPlayer.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
        state.audioState.audioPlayer.currentItem?.forwardPlaybackEndTime = CMTime(seconds: word.time + word.duration, preferredTimescale: 60000)
        state.audioState.audioPlayer.playImmediately(atRate: state.settingsState.speechSpeed.playRate)
        if let story = state.storyState.currentStory {
            return .saveStoryAndSettings(story)
        }
        return nil
    case .prepareToPlayStudyWord(let definition):
        do {
            let chapter = try environment.loadChapter(storyId: definition.timestampData.storyId,
                                                      chapterIndex: definition.timestampData.chapterIndex)
            return .updateStudyChapter(chapter)
        } catch {
            return .failedToPrepareStudyWord
        }
    case .playStudyWord(let definition):
        let myTime = CMTime(seconds: definition.timestampData.time, preferredTimescale: 60000)
        await state.studyState.audioPlayer.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
        state.studyState.audioPlayer.currentItem?.forwardPlaybackEndTime = CMTime(seconds: definition.timestampData.time + definition.timestampData.duration, preferredTimescale: 60000)
        state.studyState.audioPlayer.playImmediately(atRate: state.settingsState.speechSpeed.playRate)
        return nil
    case .playStudySentence(let startWord, let endWord):
        let myTime = CMTime(seconds: startWord.time, preferredTimescale: 60000)
        await state.studyState.audioPlayer.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
        state.studyState.audioPlayer.currentItem?.forwardPlaybackEndTime = CMTime(seconds: endWord.time + endWord.duration, preferredTimescale: 60000)
        state.studyState.audioPlayer.playImmediately(atRate: state.settingsState.speechSpeed.playRate)
        return nil
    case .playSound:
        if state.settingsState.shouldPlaySound {
            state.appAudioState.audioPlayer.play()
        }
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
            
            if let definition = state.definitionState.definition(timestampData: timeStampData, in: sentence),
               !shouldForce {
                return .onDefinedCharacter(definition)
            }

            guard let story = state.storyState.currentStory,
                  let chapter  = state.storyState.currentChapter,
                  let deviceLanguage = state.deviceLanguage,
                  let currentSentence = state.storyState.currentSentence,
                  let sentenceIndex = state.storyState.currentStory?.currentSentenceIndex else {
                return .failedToDefineCharacter
            }

            let fetchedDefinitions = try await environment.fetchDefinitions(
                for: sentenceIndex,
                in: currentSentence,
                chapter: chapter,
                story: story,
                deviceLanguage: deviceLanguage
            )

            if let tappedDefinition = fetchedDefinitions.first(where: { $0.timestampData == timeStampData }) {
                return .onDefinedSentence(fetchedDefinitions, tappedDefinition: tappedDefinition)
            }
            return .failedToDefineCharacter
        } catch {
            return .failedToDefineCharacter
        }
    case .onDefinedSentence,
            .onDefinedCharacter:
        return .saveDefinitions
    case .saveDefinitions:
        do {
            // Group definitions by story ID for more efficient storage
            let definitionsByStoryId = Dictionary(grouping: state.definitionState.definitions) { $0.timestampData.storyId }
            
            // Save each group to its own file
            for (storyId, definitions) in definitionsByStoryId {
                try environment.saveDefinitions(for: storyId, definitions: definitions)
            }
            
            return .onSavedDefinitions
        } catch {
            return .failedToSaveDefinitions
        }
    case .onSavedDefinitions:
        return .refreshDefinitionView
    case .selectChapter:
        return .onSelectedChapter
    case .onSelectedChapter:
        return .selectTab(.reader, shouldPlaySound: false)
    case .saveStoryAndSettings(var story):
        // (Optional) Some code that modifies `story.chapters` as you do now.
        // e.g. removing big audio data from older chapters or whatever else.

        do {
            // 1) Save each chapter individually.
            for (index, chapter) in story.chapters.enumerated() {
                // Chapter indexes typically start at 1, since 0 is the main story
                try environment.saveChapter(chapter, storyId: story.id, chapterIndex: index + 1)
            }

            // 2) Save the main story. (Chapters array is not persisted to JSON.)
            try environment.saveStory(story)

            // 3) Save updated settings.
            try environment.saveAppSettings(state.settingsState)

            // Return success action to update state.
            return .onSavedStoryAndSettings
        } catch {
            return .failedToSaveStoryAndSettings
        }
    case .onSavedStoryAndSettings:
        // After a story is successfully saved, check if this was a new story creation
        // and the user already has other stories
        if state.storyState.savedStories.count >= 1 {
            // Show the "story ready" snackbar that stays for 10 seconds and allows tapping to read
            return .loadThenShowReadySnackbar
        }
        return .loadStories(isAppLaunch: false)
    case .loadThenShowReadySnackbar:
        do {
            var stories = try environment.loadAllStories()
                .sorted(by: { $0.lastUpdated > $1.lastUpdated })
            return .showSnackBar(.storyReadyTapToRead)
        } catch {
            return .failedToLoadStories
        }
    case .setMusicVolume(let volume):
        state.musicAudioState.audioPlayer.setVolume(volume.float, fadeDuration: 0.2)
        return nil
    case .selectWord(let word):
        if state.audioState.isPlayingAudio {
            let myTime = CMTime(seconds: word.time, preferredTimescale: 60000)
            await state.audioState.audioPlayer.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
            state.audioState.audioPlayer.currentItem?.forwardPlaybackEndTime = CMTime(seconds: .infinity, preferredTimescale: 60000)
            state.audioState.audioPlayer.playImmediately(atRate: state.settingsState.speechSpeed.playRate)
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
            .updateDifficulty,
            .updateColorScheme,
            .updateShouldPlaySound:
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
            return .failedToGenerateImage
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
    case .selectTab(_, let shouldPlaySound):
        return shouldPlaySound ? .playSound(.actionButtonPress) : nil
    case .onLoadedStories(let stories, let isAppLaunch):
        if isAppLaunch,
           let story = stories.first,
           story.chapters.isEmpty {
            return .loadChapters(story, isAppLaunch: isAppLaunch)
        }
        return nil
    case .onLoadedChapters(let story, let chapters, let isAppLaunch):
        return isAppLaunch ? .showSnackBar(.welcomeBack) : nil
    case .deleteCustomPrompt:
        return .showSnackBar(.deletedCustomStory)
    case .failedToLoadStories,
            .failedToSaveStory,
            .failedToDefineCharacter,
            .onPlayedAudio,
            .failedToSynthesizeAudio,
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
            .updateAutoScrollEnabled,
            .hideSnackbar,
            .updateCustomPrompt,
            .updateIsShowingCustomPromptAlert,
            .failedToLoadChapters,
            .dismissFailedModerationAlert,
            .showModerationDetails,
            .updateIsShowingModerationDetails,
            .updateStudyChapter,
            .failedToPrepareStudyWord,
            .showDailyLimitExplanationScreen,
            .hasReachedFreeTrialLimit,
            .hasReachedDailyLimit,
            .showFreeLimitExplanationScreen:
        return nil
    }
}
