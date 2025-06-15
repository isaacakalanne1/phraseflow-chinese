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
import AVFoundation

/// Checks if the playback is at or near the end of the audio
/// Used to determine if we should loop back to the start when play is tapped
private func isPlaybackAtEnd(_ state: FlowTaleState) -> Bool {
    let currentTime = state.audioState.audioPlayer.currentTime().seconds

    guard let lastSentence = state.storyState.currentChapter?.sentences.last,
          let lastWordTime = lastSentence.timestamps.last?.time,
          let lastWordDuration = lastSentence.timestamps.last?.duration else {
        return false
    }
    let endTime = lastWordTime + lastWordDuration - 0.5
    
    return currentTime >= endTime
}

let flowTaleMiddleware: Middleware<FlowTaleState, FlowTaleAction, FlowTaleEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .translationAction(let translationAction):
        return await translationMiddleware(state, action, environment)
    case .studyAction(let studyAction):
        return await studyMiddleware(state, .studyAction(studyAction), environment)
    case .checkFreeTrialLimit:
        return nil

    case .createChapter(let type):
        do {
            var story: Story
            if case .existingStory(let existingStory) = type {
                story = existingStory
            } else {
                story = state.createNewStory()
            }
            story = try await environment.generateStory(story: story,
                                                        voice: state.settingsState.voice,
                                                        deviceLanguage: state.deviceLanguage,
                                                        currentSubscription: state.subscriptionState.currentSubscription)
            return .onCreatedChapter(story)
        } catch FlowTaleDataStoreError.freeUserCharacterLimitReached { // TODO: Test this still works (manually throw error within create story service logic)
            return .setSubscriptionSheetShowing(true)
        } catch FlowTaleDataStoreError.characterLimitReached(let nextAvailable) {
            return .onDailyChapterLimitReached(nextAvailable: nextAvailable)
        } catch {
            return .failedToCreateChapter
        }

    case .onCreatedChapter(let story):
        guard let chapter = story.chapters.last else {
            return .failedToCreateChapter
        }
        return .loadInitialSentenceDefinitions(chapter, story, state.definitionState.numberOfInitialSentencesToDefine)

    case .onDailyChapterLimitReached(let nextAvailable):
        return .showSnackBar(.dailyChapterLimitReached(nextAvailable: nextAvailable))

    case .failedToCreateChapter:
        return .showSnackBar(.failedToWriteChapter)
    case .showSnackBar(let type):
        state.appAudioState.audioPlayer.play()
        if let duration = type.showDuration {
            try? await Task.sleep(for: .seconds(duration))
            return .hideSnackbar
        }
        return nil
        
    case .showSnackBarThenSaveStory(let type, let story):
        state.appAudioState.audioPlayer.play()

        if let duration = type.showDuration {
            try? await Task.sleep(for: .seconds(duration))
            return .hideSnackbarThenSaveStoryAndSettings(story)
        } else {
            return .saveStoryAndSettings(story)
        }
        
    case .hideSnackbarThenSaveStoryAndSettings(_):
        if let currentStory = state.storyState.currentStory {
            return .saveStoryAndSettings(currentStory)
        } else if let firstStory = state.storyState.savedStories.first {
            return .saveStoryAndSettings(firstStory)
        }
        return nil
    case .loadStories(let isAppLaunch):
        do {
            let stories = try environment.loadAllStories()
                .sorted(by: { $0.lastUpdated > $1.lastUpdated })
            return .onLoadedStories(stories, isAppLaunch: isAppLaunch)
        } catch {
            return .failedToLoadStories
        }
    case .loadChapters(let story, let isAppLaunch):
        do {
            let chapters = try environment.loadAllChapters(for: story.id)
            return .onLoadedChapters(story, chapters, isAppLaunch: isAppLaunch)
        } catch {
            return .failedToLoadChapters
        }
    case .loadDefinitions:
        do {
            let definitions = try environment.loadDefinitions()
            return .onLoadedDefinitions(definitions)
        } catch {
            return .failedToLoadDefinitions
        }
        
    case .loadInitialSentenceDefinitions(let chapter, let story, let sentenceCount):
        do {
            let initialSentences = Array(chapter.sentences.prefix(sentenceCount))
            var allDefinitions: [Definition] = []
            
            for sentence in initialSentences {
                if let firstWord = sentence.timestamps.first {
                    let definitionsForSentence = try await environment.fetchDefinitions(
                        in: sentence,
                        story: story,
                        deviceLanguage: state.deviceLanguage ?? .english
                    )

                    try environment.saveDefinitions(definitionsForSentence)
                    allDefinitions.append(contentsOf: definitionsForSentence)
                }
            }
            try environment.saveStory(story)

            return .onLoadedInitialDefinitions(allDefinitions)
        } catch {
            return .showSnackBarThenSaveStory(.chapterReady, story)
        }
        
    case .loadRemainingDefinitions(let chapter, let story, let sentenceIndex, let definitions):
        do {
            if sentenceIndex >= chapter.sentences.count {
                return .onLoadedDefinitions([])
            }
            
            let sentence = chapter.sentences[sentenceIndex]
            
            let definitionsForSentence = try await environment.fetchDefinitions(
                in: sentence,
                story: story,
                deviceLanguage: state.deviceLanguage ?? .english
            )

            try environment.saveDefinitions(definitionsForSentence)

            return .loadRemainingDefinitions(chapter, story, sentenceIndex: sentenceIndex + 1, previousDefinitions: definitionsForSentence)
        } catch {
            return .failedToLoadDefinitions
        }
    case .deleteStory(let story):
        do {
            try environment.unsaveStory(story)
            return .onDeletedStory(story.id)
        } catch {
            return .failedToDeleteStory
        }
    case .onDeletedStory:
        return .loadStories(isAppLaunch: false)
    case .playAudio(let timestamp):
        let playRate = state.settingsState.speechSpeed.playRate

        if isPlaybackAtEnd(state) {
            await state.audioState.audioPlayer.playAudio(playRate: playRate)
        } else if let timestamp {
            await state.audioState.audioPlayer.playAudio(fromSeconds: timestamp,
                                                         playRate: playRate)
        }
        
        if let story = state.storyState.currentStory {
            return .saveStoryAndSettings(story)
        }
        return nil
    case .playWord(let word, let story):
        await state.audioState.audioPlayer.playAudio(fromSeconds: word.time,
                                                     toSeconds: word.time + word.duration,
                                                     playRate: state.settingsState.speechSpeed.playRate)
        if let story = state.storyState.currentStory {
            return .saveStoryAndSettings(story)
        }
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
        
    case .musicTrackFinished(let nextMusicType):
        return .playMusic(nextMusicType)
        
    case .stopMusic:
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
    case .defineSentence(let timestampData, let shouldForce):
        do {
            guard let sentence = state.storyState.sentence(containing: timestampData),
                  let story = state.storyState.currentStory else {
                return .failedToDefineSentence
            }

            if let definition = state.definitionState.definition(timestampData: timestampData),
               !shouldForce {
                return .onDefinedCharacter(definition)
            }

            let definitionsForSentence = try await environment.fetchDefinitions(
                in: sentence,
                story: story,
                deviceLanguage: state.deviceLanguage ?? .english
            )

            guard let definitionOfTappedWord = definitionsForSentence.first(where: { $0.timestampData == timestampData }) else {
                return .failedToDefineSentence
            }

            return .onDefinedSentence(sentence,
                                      definitionsForSentence,
                                      definitionOfTappedWord)

        } catch {
            return .failedToDefineSentence
        }
    case .onDefinedSentence(let sentence, let definitions, var tappedDefinition):
        guard let firstWord = definitions.first?.timestampData,
              let lastWord = definitions.last?.timestampData else {
            return .saveDefinitions
        }

        let startTime = firstWord.time
        let totalDuration = lastWord.time + lastWord.duration - startTime

        guard let sentenceAudio = AudioExtractor.shared.extractAudioSegment(
            from: state.audioState.audioPlayer,
            startTime: firstWord.time,
            duration: lastWord.time + lastWord.duration - firstWord.time
        ) else {
            return .saveDefinitions
        }

        do {
            try environment.saveSentenceAudio(sentenceAudio, id: sentence.id)
            tappedDefinition.sentenceId = sentence.id
            return .onDefinedCharacter(tappedDefinition)
        } catch {
            return .saveDefinitions
        }
    case .onDefinedCharacter:
        return .saveDefinitions
    case .saveDefinitions:
        do {
            try environment.saveDefinitions(state.definitionState.definitions)
        } catch {
            return .failedToSaveDefinitions
        }
        return nil
    case .deleteDefinition(let definition):
        do {
            try environment.deleteDefinition(with: definition.id)
        } catch {
            return .failedToDeleteDefinition
        }
        return nil
    case .selectChapter:
        return .onSelectedChapter
    case .onSelectedChapter:
        return .selectTab(.reader, shouldPlaySound: false)
    case .saveStoryAndSettings(var story):
        do {
            try environment.saveStory(story)
            try environment.saveAppSettings(state.settingsState)
        } catch {
            return .failedToSaveStoryAndSettings
        }
        return nil
    case .setMusicVolume(let volume):
        state.musicAudioState.audioPlayer.setVolume(volume.float, fadeDuration: 0.2)
        return nil
    case .updatePlayTime:
        let currentTime = state.audioState.audioPlayer.currentTime().seconds
        if let lastSentence = state.storyState.currentChapter?.sentences.last,
           let lastWordTime = lastSentence.timestamps.last?.time,
           let lastWordDuration = lastSentence.timestamps.last?.duration,
           currentTime > lastWordTime + lastWordDuration {
            return .pauseAudio
        }
        return nil
    case .goToNextChapter:
        if let story = state.storyState.currentStory {
            return .saveStoryAndSettings(story)
        }
        return nil
    case .selectVoice,
            .updateLanguage,
            .updateSpeechSpeed,
            .updateShowDefinition,
            .updateShowEnglish,
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
    case .checkDeviceVolumeZero:
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
        } catch {
            return nil
        }
        return audioSession.outputVolume == 0.0 ? .showSnackBar(.deviceVolumeZero) : nil
    case .fetchSubscriptions:
        environment.validateReceipt()
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
        environment.validateReceipt()
        do {
            try await AppStore.sync()
        } catch {
            return .failedToRestoreSubscriptions
        }
        return .onRestoredSubscriptions
        
    case .validateReceipt:
        environment.validateReceipt()
        return .onValidatedReceipt
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
    case .updateStudiedWord:
        return .saveDefinitions
    case .onLoadedAppSettings:
        if state.settingsState.isPlayingMusic {
            return .playMusic(.whispersOfTheForest)
        }
        return nil
    case .updateStorySetting(let setting):
        switch setting {
        case .random:
            return nil
        case .customPrompt(let prompt):
            let isNewPrompt = !state.settingsState.customPrompts.contains(prompt)
            return isNewPrompt ? .moderateText(prompt) : nil
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
    case .didNotPassModeration,
            .failedToModerateText:
        return .showSnackBar(.didNotPassModeration)
    case .selectTab(_, let shouldPlaySound):
        return shouldPlaySound ? .playSound(.tabPress) : nil
    case .onLoadedStories(let stories, let isAppLaunch):
        return .onFinishedLoadedStories
    case .onFinishedLoadedStories:
        if let story = state.storyState.currentStory,
           story.chapters.isEmpty {
            return .loadChapters(story, isAppLaunch: false)
        }
        return nil
    case .onLoadedChapters(let story, let chapters, let isAppLaunch):
        return isAppLaunch ? .showSnackBar(.welcomeBack) : nil
    case .deleteCustomPrompt:
        return .saveAppSettings
    case .onLoadedInitialDefinitions(let definitions):
        if let currentStory = state.storyState.currentStory,
           let chapter = state.storyState.currentChapter {
            return .loadRemainingDefinitions(chapter,
                                             currentStory,
                                             sentenceIndex: state.definitionState.numberOfInitialSentencesToDefine,
                                             previousDefinitions: definitions)
        }
        return .refreshDefinitionView
        
    case .onLoadedDefinitions(let definitions):
        return .refreshDefinitionView
    case .setSubscriptionSheetShowing(let isShowing):
        if isShowing {
            return .hideSnackbar
        }
        return nil
    case .failedToLoadStories,
            .failedToSaveStory,
            .failedToDefineSentence,
            .onPlayedAudio,
            .refreshChapterView,
            .refreshDefinitionView,
            .failedToDeleteStory,
            .failedToSaveAppSettings,
            .failedToLoadAppSettings,
            .refreshTranslationView,
            .failedToLoadDefinitions,
            .failedToSaveDefinitions,
            .failedToSaveStoryAndSettings,
            .refreshStoryListView,
            .onFetchedSubscriptions,
            .failedToFetchSubscriptions,
            .failedToPurchaseSubscription,
            .onRestoredSubscriptions,
            .failedToRestoreSubscriptions,
            .updateAutoScrollEnabled,
            .hideSnackbar,
            .updateCustomPrompt,
            .updateIsShowingCustomPromptAlert,
            .failedToLoadChapters,
            .dismissFailedModerationAlert,
            .showModerationDetails,
            .updateIsShowingModerationDetails,
            .showDailyLimitExplanationScreen,
            .hasReachedFreeTrialLimit,
            .hasReachedDailyLimit,
            .showFreeLimitExplanationScreen,
            .selectStoryFromSnackbar,
            .onValidatedReceipt,
            .updateIsSubscriptionPurchaseLoading,
            .updateCurrentSentence,
            .failedToDeleteDefinition,
            .clearCurrentDefinition,
            .updateLoadingState:
        return nil
    }
}
