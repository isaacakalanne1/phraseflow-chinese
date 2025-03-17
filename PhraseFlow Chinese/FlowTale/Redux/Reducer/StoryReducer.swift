//
//  StoryReducer.swift
//  FlowTale
//
//  Created by iakalann on 22/03/2025.
//
import AVKit
import ReduxKit

let storyReducer: Reducer<StoryState, StoryAction> = { state, action in

    var newState = state
    switch action {
    case .onLoadedStories(let stories, let isAppLaunch):
        newState.savedStories = stories
        newState.readerDisplayType = .normal

        if newState.shouldSelectNewCurrentStory {
            newState.currentStory = stories.first
            newState.updateAudioPlayer(newState.currentChapterAudioData)
        }
    case .onLoadedChapters(let story, let chapters, _):
        if let index = newState.savedStories.firstIndex(where: { $0.id == story.id }) {
            var updatedStory = newState.savedStories[index]
            updatedStory.chapters = chapters
            newState.savedStories[index] = updatedStory
        }

        if newState.currentStory?.id == story.id {
            newState.currentStory?.chapters = chapters
            newState.updateAudioPlayer(newState.currentChapterAudioData)
        }

    case .failedToLoadStories:
        newState.readerDisplayType = .normal
    case .createChapter(let type):
        newState.readerDisplayType = .loading(.writing)
    case .failedToCreateChapter,
            .failedToGenerateImage:
        newState.readerDisplayType = .normal
    case .onDeletedStory(let storyId):
        if newState.currentStory?.id == storyId {
            newState.currentStory = nil
        }
//        newState.viewState.storyListViewId = UUID() // TODO: May need to have story list refresh on story delete
    case .selectChapter(var story, let chapterIndex):
        story.lastUpdated = .now
        if story.chapters.count < chapterIndex {
            story.currentChapterIndex = chapterIndex
        }
        newState.currentStory = story
        newState.updateAudioPlayer(newState.currentChapterAudioData)
    case .selectStoryFromSnackbar(var story):
        story.lastUpdated = .now
        story.currentChapterIndex = story.chapters.count - 1
        newState.currentStory = story
        newState.updateAudioPlayer(newState.currentChapterAudioData)
    case .goToNextChapter:
//        newState.viewState.chapterViewId = UUID() // TODO: May need to refresh view on goto next chapter
        var newStory = newState.currentStory
        newStory?.currentChapterIndex += 1
        newStory?.currentSentenceIndex = 0
        newState.currentStory = newStory

        newState.updateAudioPlayer(newState.currentChapterAudioData)
        let chapter = newState.currentChapter
        let firstTimestamp = chapter?.sentences.first?.wordTimestamps.first
        newState.currentStory?.currentPlaybackTime = firstTimestamp?.time ?? 0.1
    case .generateImage:
        newState.readerDisplayType = .loading(.generatingImage)
    case .synthesizeAudio:
        newState.readerDisplayType = .loading(.generatingSpeech)
    case .onSynthesizedAudio(var chapter, var newStory, let isForced):
        let hasExistingStories = newState.savedStories.count > 1
        let isNewStoryCreation = newStory.chapters.count == 1

        newStory.currentPlaybackTime = 0
        newStory.currentSentenceIndex = 0
        newStory.currentChapterIndex = newStory.chapters.count - 1
        newStory.chapters[newStory.currentChapterIndex] = chapter

        if (isNewStoryCreation && !hasExistingStories) || isForced {
            newState.currentStory = newStory
            newState.updateAudioPlayer(chapter.audioData)
        }

        newState.readerDisplayType = .normal
    case .failedToSaveStory,
            .saveStoryAndSettings,
            .onSavedStoryAndSettings,
            .failedToSaveStoryAndSettings,
            .loadStories,
            .onFinishedLoadedStories,
            .loadChapters,
            .failedToLoadChapters,
            .onCreatedChapter,
            .deleteStory,
            .failedToDeleteStory,
            .onSelectedChapter,
            .onGeneratedImage,
            .failedToSynthesizeAudio:
        break
    }

    return newState
}
