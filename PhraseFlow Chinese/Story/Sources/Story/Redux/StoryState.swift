//
//  StoryState.swift
//  FlowTale
//
//  Created by iakalann on 16/11/2024.
//

import Foundation
import TextGeneration

public struct StoryState: Equatable {
    public var currentChapter: Chapter?
    public var storyChapters: [UUID: [Chapter]] = [:]
    public var isWritingChapter: Bool = false

    public init(currentChapter: Chapter? = nil,
         storyChapters: [UUID: [Chapter]] = [:],
         isWritingChapter: Bool = false) {
        self.currentChapter = currentChapter
        self.storyChapters = storyChapters
        self.isWritingChapter = isWritingChapter
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
    
    public static func == (lhs: StoryState, rhs: StoryState) -> Bool {
        lhs.currentChapter?.id == rhs.currentChapter?.id &&
        lhs.storyChapters.count == rhs.storyChapters.count
    }
}
