//
//  StoryState.swift
//  FlowTale
//
//  Created by iakalann on 16/11/2024.
//

import Foundation

struct StoryState {
    var currentStory: Story?
    var savedStories: [Story] = []
    var sentenceIndex = 0

    init(currentStory: Story? = nil,
         savedStories: [Story] = [],
         sentenceIndex: Int = 0) {
        self.currentStory = currentStory
        self.savedStories = savedStories
        self.sentenceIndex = sentenceIndex
    }

    var currentChapter: Chapter? {
        guard let currentStory else {
            return nil
        }
        return currentStory.chapters[safe: currentStory.currentChapterIndex]
    }

    var currentSentence: Sentence? {
        guard let currentChapter else {
            return nil
        }
        return currentChapter.sentences[safe: sentenceIndex]
    }

    var currentChapterAudioData: Data? {
        guard let currentStory else {
            return nil
        }
        return currentStory.chapters[safe: currentStory.currentChapterIndex]?.audioData
    }
}
