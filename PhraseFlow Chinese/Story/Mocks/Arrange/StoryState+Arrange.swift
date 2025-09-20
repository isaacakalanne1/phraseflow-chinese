//
//  StoryState+Arrange.swift
//  Story
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Foundation
import Settings
import SettingsMocks
import Story
import TextGeneration

public extension StoryState {
    static var arrange: StoryState {
        .arrange()
    }
    
    static func arrange(
        currentChapter: Chapter? = nil,
        storyChapters: [UUID: [Chapter]] = [:],
        isWritingChapter: Bool = false,
        viewState: StoryViewState = StoryViewState(),
        isPlayingChapterAudio: Bool = false,
        settings: SettingsState = .arrange
    ) -> StoryState {
        StoryState(
            currentChapter: currentChapter,
            storyChapters: storyChapters,
            isWritingChapter: isWritingChapter,
            viewState: viewState,
            isPlayingChapterAudio: isPlayingChapterAudio,
            settings: settings
        )
    }
}
