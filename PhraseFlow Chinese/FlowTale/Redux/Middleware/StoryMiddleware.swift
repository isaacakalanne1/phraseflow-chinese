//
//  StoryMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 22/03/2025.
//

import ReduxKit

typealias StoryMiddlewareType = Middleware<FlowTaleState, FlowTaleAction, FlowTaleEnvironmentProtocol>

let storyMiddleware: StoryMiddlewareType = { state, action, environment in
    switch action {
    case .storyAction(let storyAction):
        return await handleStoryAction(state: state,
                                       action: storyAction,
                                       environment: environment)
    default:
        return nil
    }

    func handleStoryAction(state: FlowTaleState,
                           action: StoryAction,
                           environment: FlowTaleEnvironmentProtocol) async -> FlowTaleAction? {
        switch action {
        case .onCreatedChapter(let story, let voice):
            if story.imageData == nil,
               let passage = story.chapters.first?.passage {
                return .storyAction(.generateImage(passage: passage, story))
            } else if let chapter = story.chapters[safe: story.currentChapterIndex] {
                return .storyAction(.synthesizeAudio(chapter,
                                                     story: story,
                                                     voice: voice,
                                                     isForced: true))
            }
            return .storyAction(.saveStoryAndSettings(story))
        case .onLoadedStories:
            return .storyAction(.onFinishedLoadedStories)
        case .createChapter(let type):
            do {
                try environment.enforceChapterCreationLimit(subscription: state.subscriptionState.currentSubscription)
                let emptyStory = Story(difficulty: state.settingsState.difficulty,
                                       language: state.settingsState.language,
                                       storyPrompt: state.settingsState.storySetting.prompt)
                var story = type.story ?? emptyStory
                story = try await environment.generateStory(story: story,
                                                            deviceLanguage: state.deviceLanguage)
                let voice = story.chapters.last?.audioVoice ?? state.settingsState.voice
                return .storyAction(.onCreatedChapter(story: story,
                                                      voice: voice))
            } catch FlowTaleDataStoreError.freeUserChapterLimitReached {
                return .setSubscriptionSheetShowing(true)
            } catch FlowTaleDataStoreError.chapterCreationLimitReached(let nextAvailable) {
                return .onDailyChapterLimitReached(nextAvailable: nextAvailable)
            } catch {
                return .storyAction(.failedToCreateChapter)
            }

        case .failedToCreateChapter,
                .failedToGenerateImage:
            return .snackBarAction(.showSnackBar(.failedToWriteChapter))
        case .saveStoryAndSettings(var story):
            do {
                for (index, chapter) in story.chapters.enumerated() {
                    try environment.saveChapter(chapter, storyId: story.id, chapterIndex: index + 1)
                }

                try environment.saveStory(story)
                try environment.saveAppSettings(state.settingsState)

                return .storyAction(.onSavedStoryAndSettings)
            } catch {
                return .storyAction(.failedToSaveStoryAndSettings)
            }
        case .onSavedStoryAndSettings:
            return  .storyAction(.loadStories(isAppLaunch: false))
        case .loadStories(let isAppLaunch):
            do {
                let stories = try environment
                    .loadAllStories()
                    .sorted(by: { $0.lastUpdated > $1.lastUpdated })
                return .storyAction(.onLoadedStories(stories, isAppLaunch: isAppLaunch))
            } catch {
                return .storyAction(.failedToLoadStories)
            }
        case .onFinishedLoadedStories:
            if let story = state.storyState.currentStory,
               story.chapters.isEmpty {
                return .storyAction(.loadChapters(story, isAppLaunch: false))
            }
            return nil
        case .loadChapters(let story, let isAppLaunch):
            do {
                let chapters = try environment.loadAllChapters(for: story.id)
                return .storyAction(.onLoadedChapters(story, chapters, isAppLaunch: isAppLaunch))
            } catch {
                return .storyAction(.failedToLoadChapters)
            }
        case .onLoadedChapters(_, _, let isAppLaunch):
            return isAppLaunch ? .snackBarAction(.showSnackBar(.welcomeBack)) : nil
        case .deleteStory(let story):
            do {
                try environment.unsaveStory(story)
                return .storyAction(.onDeletedStory(story.id))
            } catch {
                return .storyAction(.failedToDeleteStory)
            }
        case .onDeletedStory:
            return .storyAction(.loadStories(isAppLaunch: false))
        case .selectChapter:
            return .storyAction(.onSelectedChapter)
        case .onSelectedChapter:
            return .selectTab(.reader, shouldPlaySound: false)
        case .goToNextChapter:
            if let story = state.storyState.currentStory {
                return .storyAction(.saveStoryAndSettings(story))
            }
            return nil
        case .generateImage(let passage, let story):
            do {
                let data = try await environment.generateImage(with: passage)
                return .storyAction(.onGeneratedImage(data, story))
            } catch {
                return .storyAction(.failedToGenerateImage)
            }
        case .onGeneratedImage(let data, var story):
            story.imageData = data
            if let chapter = story.chapters[safe: story.currentChapterIndex],
               let voice = chapter.audioVoice {
                return .storyAction(.synthesizeAudio(chapter,
                                                     story: story,
                                                     voice: voice,
                                                     isForced: true))
            }
            return .storyAction(.saveStoryAndSettings(story))
        case .synthesizeAudio(let chapter, let story, let voice, let isForced):
            if chapter.audioData != nil,
               !isForced {
                return .playAudio(time: nil)
            }
            do {
                let newChapter = try await environment.synthesizeSpeech(for: chapter,
                                                                        story: story,
                                                                        voice: voice,
                                                                        language: story.language)
                return .storyAction(.onSynthesizedAudio(newChapter, story, isForced: isForced))
            } catch {
                return .storyAction(.failedToSynthesizeAudio)
            }
        case .onSynthesizedAudio(_, let story, _):
            return.snackBarAction(.showSnackBarThenSaveStory(.chapterReady, story))
        case .selectStoryFromSnackbar:
            return .selectTab(.reader, shouldPlaySound: false)
        case .failedToSaveStory,
                .failedToLoadChapters,
                .failedToDeleteStory,
                .failedToLoadStories,
                .failedToSaveStoryAndSettings,
                .failedToSynthesizeAudio:
            return nil
        }
    }

}
