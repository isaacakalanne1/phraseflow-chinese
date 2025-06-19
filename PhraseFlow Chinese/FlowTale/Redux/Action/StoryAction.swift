//
//  StoryAction.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation

enum StoryAction {
    case createChapter(CreateChapterType)
    case onCreatedChapter(Story)
    case failedToCreateChapter

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

    case saveStoryAndSettings(Story)
    case failedToSaveStoryAndSettings
    case goToNextChapter
}
