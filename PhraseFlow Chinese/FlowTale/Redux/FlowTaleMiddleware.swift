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

/// Checks if the playback is at or near the end of the audio
/// Used to determine if we should loop back to the start when play is tapped
private func isPlaybackAtEnd(_ state: FlowTaleState) -> Bool {
    // Get current time
    let currentTime = state.audioState.audioPlayer.currentTime().seconds
    
    // Get the timestamp of the last word
    guard let lastWordTime = state.storyState.currentChapter?.audio.timestamps.last?.time,
          let lastWordDuration = state.storyState.currentChapter?.audio.timestamps.last?.duration else {
        return false
    }
    
    // Consider the end as being after the last word's timestamp plus its duration
    // Add a small buffer (0.5 seconds) to account for minor timing differences
    let endTime = lastWordTime + lastWordDuration - 0.5
    
    // Return true if current time is at or past the end time
    return currentTime >= endTime
}

let flowTaleMiddleware: FlowTaleMiddlewareType = { state, action, environment in
    switch action {
    case .onCreatedChapter(let story):
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
            let story: Story
            switch type {
            case .newStory:
                let newStory = state.createNewStory()
                story = try await environment.generateStory(story: newStory,
                                                            deviceLanguage: state.deviceLanguage)
            case .existingStory(let existingStory):
                story = try await environment.generateStory(story: existingStory,
                                                            deviceLanguage: state.deviceLanguage)
            }
            return .onCreatedChapter(story: story)
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
            .failedToGenerateImage:
        return .showSnackBar(.failedToWriteChapter)
    case .showSnackBar(let type):
        state.appAudioState.audioPlayer.play()
        if let duration = type.showDuration {
            try? await Task.sleep(for: .seconds(duration))
            return .hideSnackbar
        }
        return nil
        
    case .showSnackBarThenSaveStory(let type, let story):
        // First show the snackbar
        state.appAudioState.audioPlayer.play()

        // Hide the snackbar after its duration, then save the story
        if let duration = type.showDuration {
            try? await Task.sleep(for: .seconds(duration))
            return .hideSnackbarThenSaveStoryAndSettings(story)
        }
        // If no duration, just save directly
        return .saveStoryAndSettings(story)
        
    case .hideSnackbarThenSaveStoryAndSettings(_):
        // Get the current story from state, which will have the updated chapter data
        // This ensures we use the latest story with all modifications from the reducer
        if let currentStory = state.storyState.currentStory {
            return .saveStoryAndSettings(currentStory)
        } else if let firstStory = state.storyState.savedStories.first {
            // Fallback to the first story if current story is nil
            return .saveStoryAndSettings(firstStory)
        }
        // No story to save
        return nil
        
    case .loadDefaultStory(let language):
        // Load default stories for the specified language
        let defaultStories = environment.loadDefaultBundleStories(forLanguage: language)

        // If we found a default story for this language, return it
        if let defaultStory = defaultStories.first {
            // Save the default story to the data store
            do {
                try environment.saveStory(defaultStory)
                
                // Save each chapter
                for (index, chapter) in defaultStory.chapters.enumerated() {
                    try environment.saveChapter(chapter, storyId: defaultStory.id, chapterIndex: index + 1)
                }
                
                return .onLoadedDefaultStory(defaultStory)
            } catch {
                return .failedToLoadDefaultStory
            }
        } else {
            // No default story found for this language
            return .failedToLoadDefaultStory
        }
        
    case .saveAsDefaultStory(let story):
        // Create a copy of the story and mark it as a default story
        var storyCopy = story
        storyCopy.isDefaultStory = true
        
        // Create a unique filename based on the language and date
        let languageKey = storyCopy.language.key.lowercased()
        let filename = "default_story_\(languageKey)_\(storyCopy.id.uuidString).json"
        
        // Save to the documents directory for easy access
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("⚠️ Failed to get documents directory")
            return .failedToSaveAsDefaultStory
        }
        
        let docsURL = documentsDirectory.appendingPathComponent(filename)
        
        // Encode the story
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(storyCopy)
            try data.write(to: docsURL)
            print("✅ Default story saved to: \(docsURL.path)")
            print("Copy this file to your project's resources to include it in the app bundle")
            return .onSavedAsDefaultStory(docsURL)
        } catch {
            print("⚠️ Failed to save default story: \(error.localizedDescription)")
            return .failedToSaveAsDefaultStory
        }
        
    case .loadDefaultStory(let language):
        // Load default stories for the specified language
        let defaultStories = environment.loadDefaultBundleStories(forLanguage: language)
        
        // If we found a default story for this language, return it
        if let defaultStory = defaultStories.first {
            // Save the default story to the data store
            do {
                try environment.saveStory(defaultStory)
                
                // Save each chapter
                for (index, chapter) in defaultStory.chapters.enumerated() {
                    try environment.saveChapter(chapter, storyId: defaultStory.id, chapterIndex: index + 1)
                }
                
                return .onLoadedDefaultStory(defaultStory)
            } catch {
                return .failedToLoadDefaultStory
            }
        } else {
            // No default story found for this language
            return .failedToLoadDefaultStory
        }
        
    case .deleteDefaultStories(let language):
        // Get documents directory
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("⚠️ Failed to get documents directory")
            return .failedToDeleteDefaultStories
        }
        
        do {
            // Get all files in the documents directory
            let fileManager = FileManager.default
            let files = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            
            // Filter for default story files
            let defaultStoryFiles = files.filter { fileURL in
                let filename = fileURL.lastPathComponent
                if language == nil {
                    // If no language specified, match all default story files
                    return filename.hasPrefix("default_story_") && filename.hasSuffix(".json")
                } else {
                    // If language specified, only match files for that language
                    let languageKey = language!.key.lowercased()
                    return filename.hasPrefix("default_story_\(languageKey)_") && filename.hasSuffix(".json")
                }
            }
            
            // Delete each matching file
            if !defaultStoryFiles.isEmpty {
                for fileURL in defaultStoryFiles {
                    try fileManager.removeItem(at: fileURL)
                    print("🗑️ Deleted default story: \(fileURL.lastPathComponent)")
                }
                return .onDeletedDefaultStories
            } else {
                print("ℹ️ No default stories found to delete")
                return .onDeletedDefaultStories // Still return success even if no files found
            }
        } catch {
            print("⚠️ Failed to delete default stories: \(error.localizedDescription)")
            return .failedToDeleteDefaultStories
        }
    case .loadStories(let isAppLaunch):
        do {
            var stories = try environment.loadAllStories()
                .sorted(by: { $0.lastUpdated > $1.lastUpdated })
                
            // Add default stories if the user doesn't have any stories yet
            if isAppLaunch && stories.isEmpty {
                // Load default stories from the app bundle (all languages)
                let defaultStories = environment.loadDefaultBundleStories(forLanguage: nil)

                // If we found any default stories, add them and save them to the data store
                if !defaultStories.isEmpty {
                    for defaultStory in defaultStories {
                        // Save the default story to the data store
                        try environment.saveStory(defaultStory)
                        
                        // Save each chapter
                        for (index, chapter) in defaultStory.chapters.enumerated() {
                            try environment.saveChapter(chapter, storyId: defaultStory.id, chapterIndex: index + 1)
                        }
                    }
                    
                    // Add default stories to our stories array
                    stories.append(contentsOf: defaultStories)
                }
            }
            
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
            try environment.unsaveStory(story)

            // Pass the hidden story ID
            return .onDeletedStory(story.id)
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
    case .onSynthesizedAudio(_, let story, _):
        // Determine which type of snackbar to show based on the story
        let isNewStoryCreation = story.chapters.count == 1
        let hasExistingStories = state.storyState.savedStories.count > 1
        
        // We'll let the reducer handle updating the state with this story first 
        // before we do anything else, so we don't need to pass the story along
        
        // Show appropriate snackbar first
        return .showSnackBarThenSaveStory(.chapterReady, story)
    case .playAudio(let timestamp):
        // Check if playback is at or near the end
        let isAtEnd = isPlaybackAtEnd(state)
        
        if isAtEnd {
            await state.audioState.audioPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 60000), toleranceBefore: .zero, toleranceAfter: .zero)
            print("Looping back to start because play button was tapped at the end")
        } else if let timestamp {
            // If timestamp is provided, use it to seek
            let myTime = CMTime(seconds: timestamp, preferredTimescale: 60000)
            await state.audioState.audioPlayer.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
        }
        
        // Set the end time to infinity and start playback
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
        let playLength = endWord.time + endWord.duration - startWord.time
        let speedModifiedPlayLength = playLength / Double(state.settingsState.speechSpeed.playRate)

        try? await Task.sleep(for: .seconds(speedModifiedPlayLength))

        if let duration = state.studyState.audioPlayer.currentItem?.duration.seconds,
           duration >= playLength {
            return .updateStudyAudioPlaying(false)
        }
        return nil

    case .pauseStudyAudio:
        state.studyState.audioPlayer.pause()
        return .updateStudyAudioPlaying(false)
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
        // Play the next track in the music rotation
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
    case .onDefinedSentence:
        return .saveDefinitions
    case .onDefinedCharacter(var definition):
        if let audio = await state.storyState.currentChapter?.audio.data.extractAudioSegment(startTime: definition.timestampData.time, duration: definition.timestampData.duration) {
            print("Here!!")
        } else {
            print("Not yet!")
        }
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
    case .deleteDefinition:
        // After updating the definition in the state, save the changes
        return .saveDefinitions
    case .onDeletedDefinition:
        return .loadDefinitions
    case .onSavedDefinitions:
        return .loadDefinitions
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
        // Just load stories after saving - we already show snackbars in the reducer
        return .loadStories(isAppLaunch: false)
    case .loadThenShowReadySnackbar:
        do {
            try environment.loadAllStories() // Refresh the stories in the environment
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
        
    case .updatePlayTime:
        let time = state.audioState.audioPlayer.currentTime().seconds
        if let lastWordTime = state.storyState.currentChapter?.audio.timestamps.last?.time,
           let lastWordDuration = state.storyState.currentChapter?.audio.timestamps.last?.duration,
           time > lastWordTime + lastWordDuration {
            // Audio has reached the end naturally (not from user tapping play)
            // Just pause it instead of looping
            return .pauseAudio
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
                return .showSnackBar(.deviceVolumeZero)
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
            return .playMusic(.whispersOfTheForest)
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
        return shouldPlaySound ? .playSound(.tabPress) : nil
    case .onLoadedStories(let stories, let isAppLaunch):
        // If current story no longer exists (deleted) and there are other stories, 
        // load chapters for the first story to ensure proper setup
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
    case .onLoadedDefinitions:
        return .refreshDefinitionView
    case .setSubscriptionSheetShowing(let isShowing):
        if isShowing {
            return .hideSnackbar
        }
        return nil
    case .onDeletedDefaultStories:
        return .showSnackBar(.deletedDefaultStories)
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
            .updateStudyChapter,
            .failedToPrepareStudyWord,
            .showDailyLimitExplanationScreen,
            .hasReachedFreeTrialLimit,
            .hasReachedDailyLimit,
            .showFreeLimitExplanationScreen,
            .selectStoryFromSnackbar,
            .updateStudyAudioPlaying,
            .onValidatedReceipt,
            .updateIsSubscriptionPurchaseLoading,
            .onSavedAsDefaultStory,
            .failedToSaveAsDefaultStory,
            .onLoadedDefaultStory,
            .failedToLoadDefaultStory,
            .failedToDeleteDefaultStories:
        return nil
    }
}
