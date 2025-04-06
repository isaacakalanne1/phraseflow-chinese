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
        guard let story = currentStory else {
            return nil
        }
        return story.chapters[safe: story.currentChapterIndex]
    }

    var currentSpokenWord: WordTimeStampData? {
        guard let playbackTime = currentStory?.currentPlaybackTime else {
            return nil
        }
        return currentChapter?.sentences.flatMap({ $0.timestamps}).last(where: { playbackTime >= $0.time })
    }

    var currentSentence: Sentence? {
        return currentChapter?.sentences.first(where: { $0.timestamps.contains(where: { $0 == currentSpokenWord }) })
    }

    var currentChapterAudioData: Data? {
        currentChapter?.audio.data
    }
}
