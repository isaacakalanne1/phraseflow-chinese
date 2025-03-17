//
//  StoryAction.swift
//  FlowTale
//
//  Created by iakalann on 22/03/2025.
//

import Foundation

enum StoryAction {
    case createChapter(CreateChapterType)
    case onCreatedChapter(story: Story, voice: Voice)
    case failedToCreateChapter
    case failedToSaveStory

    case saveStoryAndSettings(Story)
    case onSavedStoryAndSettings
    case failedToSaveStoryAndSettings

    case loadStories(isAppLaunch: Bool)
    case onLoadedStories([Story], isAppLaunch: Bool)
    case onFinishedLoadedStories
    case failedToLoadStories

    case loadChapters(Story, isAppLaunch: Bool)
    case onLoadedChapters(Story, [Chapter], isAppLaunch: Bool)
    case failedToLoadChapters

    case deleteStory(Story)
    case onDeletedStory(UUID)
    case failedToDeleteStory

    case selectChapter(Story, chapterIndex: Int)
    case selectStoryFromSnackbar(Story)
    case onSelectedChapter

    case goToNextChapter
    
    case generateImage(passage: String, Story)
    case onGeneratedImage(Data, Story)
    case failedToGenerateImage

    case synthesizeAudio(Chapter,
                         story: Story,
                         voice: Voice,
                         isForced: Bool)
    case onSynthesizedAudio(Chapter,
                            Story,
                            isForced: Bool)
    case failedToSynthesizeAudio
}
