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

typealias FlowTaleMiddlewareType = Middleware<FlowTaleState, FlowTaleAction, FlowTaleEnvironmentProtocol>

let flowTaleMiddleware: FlowTaleMiddlewareType = { state, action, environment in
    switch action {
    case .settingsAction(let settingsAction):
        return await settingsMiddleware(state,
                                        .settingsAction(settingsAction),
                                        environment)
    case .storyAction(let storyAction):
        return await storyMiddleware(state,
                                     .storyAction(storyAction),
                                     environment)
    case .studyAction(let studyAction):
        return await studyMiddleware(state,
                                     .studyAction(studyAction),
                                     environment)
    case .snackBarAction(let snackBarAction):
        return await snackBarMiddleware(state,
                                        .snackBarAction(snackBarAction),
                                        environment)
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
    case .onDailyChapterLimitReached(let nextAvailable):
        return .snackBarAction(.showSnackBar(.dailyChapterLimitReached(nextAvailable: nextAvailable)))

    case .hideSnackbarThenSaveStoryAndSettings:
        if let currentStory = state.storyState.currentStory {
            return .storyAction(.saveStoryAndSettings(currentStory))
        } else if let firstStory = state.storyState.savedStories.first {
            return .storyAction(.saveStoryAndSettings(firstStory))
        }
        return nil
    case .playAudio(let timestamp):

        let time: CMTime
        if state.storyState.isPlaybackAtEnd {
            time = CMTime(seconds: 0, preferredTimescale: 60000)
        } else if let timestamp {
            time = CMTime(seconds: timestamp, preferredTimescale: 60000)
        } else {
            time = CMTime(seconds: 0, preferredTimescale: 60000)
        }
        await state.storyState.audioPlayer.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)

        state.storyState.audioPlayer.currentItem?.forwardPlaybackEndTime = CMTime(seconds: .infinity, preferredTimescale: 1)
        state.storyState.audioPlayer.playImmediately(atRate: state.settingsState.speechSpeed.playRate)

        if let story = state.storyState.currentStory {
            return .storyAction(.saveStoryAndSettings(story))
        }
        return nil
    case .playWord(let word, let story):
        let myTime = CMTime(seconds: word.time, preferredTimescale: 60000)
        await state.storyState.audioPlayer.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
        state.storyState.audioPlayer.currentItem?.forwardPlaybackEndTime = CMTime(seconds: word.time + word.duration, preferredTimescale: 60000)
        state.storyState.audioPlayer.playImmediately(atRate: state.settingsState.speechSpeed.playRate)
        if let story = state.storyState.currentStory {
            return .storyAction(.saveStoryAndSettings(story))
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
            return .storyAction(.saveStoryAndSettings(story))
        }
        return nil
        
    case .musicTrackFinished(let nextMusicType):
        // Play the next track in the music rotation
        return .playMusic(nextMusicType)
        
    case .stopMusic:
        if let story = state.storyState.currentStory {
            return .storyAction(.saveStoryAndSettings(story))
        }
        return nil
    case .pauseAudio:
        state.storyState.audioPlayer.pause()
        if let story = state.storyState.currentStory {
            return .storyAction(.saveStoryAndSettings(story))
        }
        return nil
    case .defineCharacter(let timeStampData, let shouldForce):
        // First check if we already have a definition for this timestamp
        if timeStampData.definition != nil,
           !shouldForce {
            return .onDefinedCharacter(timeStampData)
        }

        // Find the current sentence containing this timestamp
        guard let story = state.storyState.currentStory,
              let chapter = state.storyState.currentChapter,
              let deviceLanguage = state.deviceLanguage else {
            return .failedToDefineCharacter
        }

        // Find which sentence contains this timestamp
        var currentSentence: Sentence? = nil
        var sentenceIndex = 0

        for (index, sentence) in chapter.sentences.enumerated() {
            if sentence.wordTimestamps.contains(where: { $0.id == timeStampData.id }) {
                currentSentence = sentence
                sentenceIndex = index
                break
            }
        }

        guard let currentSentence = currentSentence else {
            return .failedToDefineCharacter
        }

        guard let fetchedDefinitions = try? await environment.fetchDefinitions(
            for: sentenceIndex,
            in: currentSentence,
            chapter: chapter,
            story: story,
            deviceLanguage: deviceLanguage
        ) else {
            return .failedToDefineCharacter
        }

        return .onDefinedSentence(fetchedDefinitions, tappedWord: timeStampData)
    case .onDefinedSentence,
            .onDefinedCharacter:
        if let story = state.storyState.currentStory {
            return .storyAction(.saveStoryAndSettings(story))
        }
        return nil
    case .loadThenShowReadySnackbar:
        do {
            try environment.loadAllStories() // Refresh the stories in the environment
            return .snackBarAction(.showSnackBar(.storyReadyTapToRead))
        } catch {
            return .storyAction(.failedToLoadStories)
        }
    case .setMusicVolume(let volume):
        state.musicAudioState.audioPlayer.setVolume(volume.float, fadeDuration: 0.2)
        return nil
    case .selectWord(let word):
        if state.storyState.isPlayingAudio {
            let myTime = CMTime(seconds: word.time, preferredTimescale: 60000)
            await state.storyState.audioPlayer.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
            state.storyState.audioPlayer.currentItem?.forwardPlaybackEndTime = CMTime(seconds: .infinity, preferredTimescale: 60000)
            state.storyState.audioPlayer.playImmediately(atRate: state.settingsState.speechSpeed.playRate)
        } else {
            return .playWord(word, story: state.storyState.currentStory)
        }
        if let story = state.storyState.currentStory {
            return .storyAction(.saveStoryAndSettings(story))
        }
        return nil
        
    case .updatePlayTime:
        let time = state.storyState.audioPlayer.currentTime().seconds
        guard let chapter = state.storyState.currentChapter,
              !chapter.sentences.isEmpty,
              let lastSentence = chapter.sentences.last,
              !lastSentence.wordTimestamps.isEmpty,
              let lastWord = lastSentence.wordTimestamps.last else {
            return nil
        }
        
        if time > lastWord.time + lastWord.duration {
            // Audio has reached the end naturally (not from user tapping play)
            // Just pause it instead of looping
            return .pauseAudio
        }
        return nil
    case .selectVoice,
            .updateLanguage,
            .updateSpeechSpeed,
            .updateShowDefinition,
            .updateShowEnglish,
            .updateDifficulty,
            .updateShouldPlaySound:
        return .settingsAction(.saveAppSettings)
    case .updateSentenceIndex:
        return .refreshTranslationView
        
    case .checkDeviceVolumeZero:
        // Check if the device is in silent mode using audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
            // In iOS, outputVolume of 0 indicates silent mode
            let isSilent = audioSession.outputVolume == 0.0
            if isSilent {
                return .snackBarAction(.showSnackBar(.deviceVolumeZero))
            }
        } catch {
            print("Failed to check silent mode: \(error)")
        }
        return nil
    case .fetchSubscriptions:
        do {
            // First validate the receipt to properly handle sandbox receipts
            // This will trigger a receipt refresh if needed
            environment.validateReceipt()
            
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
            // Validate receipt first to handle sandbox receipts properly
            environment.validateReceipt()
            
            // Then perform the sync
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
                    return .snackBarAction(.showSnackBar(.subscribed))
                } else {
                    return nil
                }
            }
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
        return .snackBarAction(.showSnackBar(.passedModeration))
    case .didNotPassModeration:
        return .snackBarAction(.showSnackBar(.didNotPassModeration))
    case .failedToModerateText:
        return .snackBarAction(.showSnackBar(.didNotPassModeration))
    case .selectTab(_, let shouldPlaySound):
        return shouldPlaySound ? .playSound(.tabPress) : nil
    case .loadDefinitions(let language):
        var allChapters: [Chapter] = []
        var studySentences: [Sentence] = []
        for story in state.storyState.savedStories.filter({ $0.language == language }) {
            do {
                let chapters = try environment.loadAllChapters(for: story.id)
                let sentences = chapters
                    .flatMap({ $0.sentences })
                    .filter({
                        $0.wordTimestamps.contains(where: {
                            $0.hasBeenSeen && $0.definition != nil
                        })
                    })
                studySentences.append(contentsOf: sentences)
            } catch {
                return .failedToLoadDefinitions
            }
        }
        return .onLoadedDefinitions(studySentences)
    case .deleteCustomPrompt:
        return .settingsAction(.saveAppSettings)
    case .setSubscriptionSheetShowing(let isShowing):
        return isShowing ? .snackBarAction(.hideSnackbar) : nil
    case .updateStudiedWord(var word, let sentence):
        do {
            let chapter = try environment.loadChapter(storyId: word.storyId,
                                                      chapterIndex: sentence.chapterIndex)
            var chapters = try environment.loadAllChapters(for: word.storyId)
            if let chapter = chapters[safe: sentence.chapterIndex],
               let sentenceIndex = chapter.sentences.firstIndex(where: { $0.id == sentence.id }),
               let wordIndex = sentence.wordTimestamps.firstIndex(where: { $0.id == word.id }) {
                if var definition = word.definition {
                    definition.studiedDates.append(.now)
                    word.definition = definition
                    chapters[sentence.chapterIndex].sentences[sentenceIndex].wordTimestamps[wordIndex] = word
                }
            }
            guard var story = state.storyState.savedStories.first(where: { $0.id == word.storyId }) else {
                return nil  // TODO: Add fail return here
            }
            story.chapters = chapters
            return .storyAction(.saveStoryAndSettings(story))
        } catch {
            return nil // TODO: Add fail return here
        }
    case .deleteDefinition(var word, let sentence):
        do {
            var chapters = try environment.loadAllChapters(for: word.storyId)
            if let chapterIndex = chapters.firstIndex(where: { $0.id == sentence.chapterId }),
               let sentenceIndex = chapters[chapterIndex].sentences.firstIndex(where: { $0 == sentence }),
               let wordIndex = sentence.wordTimestamps.firstIndex(where: { $0.id == word.id }) {
                if var definition = word.definition {
                    definition.studiedDates = []
                    word.hasBeenSeen = false
                    word.definition = definition
                    chapters[chapterIndex].sentences[sentenceIndex].wordTimestamps[wordIndex] = word
                }
            }
            guard var story = state.storyState.savedStories.first(where: { $0.id == word.storyId }) else {
                return nil  // TODO: Add fail return here
            }
            story.chapters = chapters
            return .storyAction(.saveStoryAndSettings(story))
        } catch {
            return nil // TODO: Add fail return here
        }
    case .failedToDefineCharacter,
            .onPlayedAudio,
            .refreshChapterView,
            .refreshDefinitionView,
            .refreshTranslationView,
            .refreshStoryListView,
            .onFetchedSubscriptions,
            .failedToFetchSubscriptions,
            .failedToPurchaseSubscription,
            .onRestoredSubscriptions,
            .failedToRestoreSubscriptions,
            .updateAutoScrollEnabled,
            .updateCustomPrompt,
            .updateIsShowingCustomPromptAlert,
            .dismissFailedModerationAlert,
            .showModerationDetails,
            .updateIsShowingModerationDetails,
            .showDailyLimitExplanationScreen,
            .hasReachedFreeTrialLimit,
            .hasReachedDailyLimit,
            .showFreeLimitExplanationScreen,
            .onValidatedReceipt,
            .updateIsSubscriptionPurchaseLoading,
            .onLoadedDefinitions,
            .failedToLoadDefinitions:
        return nil
    }
}
