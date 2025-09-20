//
//  StoryState.swift
//  FlowTale
//
//  Created by iakalann on 16/11/2024.
//

import Foundation
import TextGeneration
import Loading
import Settings

public struct StoryState: Equatable {
    public var currentChapter: Chapter?
    public var storyChapters: [UUID: [Chapter]] = [:]
    public var isWritingChapter: Bool = false
    public var viewState: StoryViewState = StoryViewState()
    public var isPlayingChapterAudio = false
    public var settings: SettingsState = SettingsState()

    public init(
        currentChapter: Chapter? = nil,
        storyChapters: [UUID: [Chapter]] = [:],
        isWritingChapter: Bool = false,
        viewState: StoryViewState = StoryViewState(),
        isPlayingChapterAudio: Bool = false,
        settings: SettingsState = SettingsState()
    ) {
        self.currentChapter = currentChapter
        self.storyChapters = storyChapters
        self.isWritingChapter = isWritingChapter
        self.viewState = viewState
        self.isPlayingChapterAudio = isPlayingChapterAudio
        self.settings = settings
    }
    
    public var allStories: [(storyId: UUID, chapters: [Chapter])] {
        return storyChapters.map { (storyId: $0.key, chapters: $0.value) }
            .sorted { first, second in
                guard let firstLatest = first.chapters.max(by: { $0.lastUpdated < $1.lastUpdated }),
                      let secondLatest = second.chapters.max(by: { $0.lastUpdated < $1.lastUpdated }) else {
                    return false
                }
                return firstLatest.lastUpdated > secondLatest.lastUpdated
            }
    }
    
    public func firstChapter(for storyId: UUID) -> Chapter? {
        guard let chapters = storyChapters[storyId] else { return nil }
        return chapters.min(by: { $0.lastUpdated < $1.lastUpdated })
    }
    
    var isLastChapter: Bool {
        guard let currentChapter = currentChapter,
              let chapters = storyChapters[currentChapter.storyId],
              let currentIndex = chapters.firstIndex(where: { $0.id == currentChapter.id }) else { return false }
        return currentIndex >= chapters.count - 1
    }
}

public struct StoryViewState: Equatable {
    public var loadingState: LoadingStatus? = .complete
    public var isDefining: Bool = false
    public var isWritingChapter: Bool = false
    
    public init(loadingState: LoadingStatus? = .complete,
                isDefining: Bool = false,
                isWritingChapter: Bool = false) {
        self.loadingState = loadingState
        self.isDefining = isDefining
        self.isWritingChapter = isWritingChapter
    }
}
