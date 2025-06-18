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

let flowTaleMiddleware: Middleware<FlowTaleState, FlowTaleAction, FlowTaleEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .translationAction(let translationAction):
        return await translationMiddleware(state, action, environment)
    case .studyAction(let studyAction):
        return await studyMiddleware(state, .studyAction(studyAction), environment)
    case .storyAction(let storyAction):
        return await storyMiddleware(state, .storyAction(storyAction), environment)
    case .audioAction(let audioAction):
        return await audioMiddleware(state, .audioAction(audioAction), environment)
    case .checkFreeTrialLimit:
        return nil

    case .onDailyChapterLimitReached(let nextAvailable):
        return .showSnackBar(.dailyChapterLimitReached(nextAvailable: nextAvailable))

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
            return .storyAction(.saveStoryAndSettings(story))
        }
        
    case .hideSnackbarThenSaveStoryAndSettings(_):
        if let currentStory = state.storyState.currentStory {
            return .storyAction(.saveStoryAndSettings(currentStory))
        } else if let firstStory = state.storyState.savedStories.first {
            return .storyAction(.saveStoryAndSettings(firstStory))
        }
        return nil
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
            return .audioAction(.playMusic(.whispersOfTheForest))
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
        return shouldPlaySound ? .audioAction(.playSound(.tabPress)) : nil
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
    case .failedToSaveStory,
            .failedToDefineSentence,
            .refreshChapterView,
            .refreshDefinitionView,
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
