//
//  StoryState.swift
//  FlowTale
//
//  Created by iakalann on 16/11/2024.
//

import Foundation

struct StoryState {
    var currentStoryId: UUID?
    var currentChapterIndex: Int = 0
    var storyChapters: [UUID: [Chapter]] = [:]

    init(currentStoryId: UUID? = nil,
         currentChapterIndex: Int = 0,
         storyChapters: [UUID: [Chapter]] = [:]) {
        self.currentStoryId = currentStoryId
        self.currentChapterIndex = currentChapterIndex
        self.storyChapters = storyChapters
    }

    var currentChapter: Chapter? {
        guard let currentStoryId,
              let chapters = storyChapters[currentStoryId] else {
            return nil
        }
        return chapters[safe: currentChapterIndex]
    }
    
    var allStories: [(storyId: UUID, chapters: [Chapter])] {
        return storyChapters.map { (storyId: $0.key, chapters: $0.value) }
            .sorted { first, second in
                guard let firstLatest = first.chapters.max(by: { $0.lastUpdated < $1.lastUpdated }),
                      let secondLatest = second.chapters.max(by: { $0.lastUpdated < $1.lastUpdated }) else {
                    return false
                }
                return firstLatest.lastUpdated > secondLatest.lastUpdated
            }
    }
    
    func latestChapter(for storyId: UUID) -> Chapter? {
        guard let chapters = storyChapters[storyId] else { return nil }
        return chapters.max(by: { $0.lastUpdated < $1.lastUpdated })
    }

    var currentSpokenWord: WordTimeStampData? {
        guard let currentChapter else { return nil }
        let playbackTime = currentChapter.currentPlaybackTime
        return currentChapter.sentences.flatMap({ $0.timestamps}).last(where: { playbackTime >= $0.time })
    }

    var currentSentence: Sentence?
}
