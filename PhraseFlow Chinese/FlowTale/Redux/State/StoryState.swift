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

    init(currentStory: Story? = nil,
         savedStories: [Story] = []) {
        self.currentStory = currentStory
        self.savedStories = savedStories
    }

    var currentChapter: Chapter? {
        guard let currentStory else {
            return nil
        }
        return currentStory.chapters[safe: currentStory.currentChapterIndex]
    }

    var currentSentence: Sentence? {
        guard let sentenceIndex = currentStory?.currentSentenceIndex else {
            return nil
        }
        return currentChapter?.sentences[safe: sentenceIndex]
    }

    var currentChapterAudioData: Data? {
        currentChapter?.audioData
    }
}
