//
//  StoryState.swift
//  FlowTale
//
//  Created by iakalann on 16/11/2024.
//

import Foundation

struct StoryState {
    var currentChapter: Chapter?
    var storyChapters: [UUID: [Chapter]] = [:]

    init(currentChapter: Chapter? = nil,
         storyChapters: [UUID: [Chapter]] = [:]) {
        self.currentChapter = currentChapter
        self.storyChapters = storyChapters
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
    
    func firstChapter(for storyId: UUID) -> Chapter? {
        guard let chapters = storyChapters[storyId] else { return nil }
        return chapters.min(by: { $0.lastUpdated < $1.lastUpdated })
    }

    var currentSpokenWord: WordTimeStampData? {
        guard let currentChapter else { return nil }
        let playbackTime = currentChapter.currentPlaybackTime
        return currentChapter.sentences.flatMap({ $0.timestamps}).last(where: { playbackTime >= $0.time })
    }
}
