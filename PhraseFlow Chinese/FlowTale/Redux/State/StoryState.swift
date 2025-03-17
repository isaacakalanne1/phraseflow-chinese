//
//  StoryState.swift
//  FlowTale
//
//  Created by iakalann on 16/11/2024.
//

import AVKit
import Foundation

struct StoryState {
    var currentStory: Story?
    var savedStories: [Story] = []
    var readerDisplayType: ReaderDisplayType

    var audioPlayer = AVPlayer()
    var isPlayingAudio = false

    init(currentStory: Story? = nil,
         savedStories: [Story] = [],
         readerDisplayType: ReaderDisplayType = .initialising) {
        self.currentStory = currentStory
        self.savedStories = savedStories
        self.readerDisplayType = readerDisplayType
    }

    var currentSpokenWord: WordTimeStampData? {
        guard let playbackTime = currentStory?.currentPlaybackTime,
              let chapter = currentChapter else {
            return nil
        }

        // Flatten all word timestamps from all sentences
        let allTimestamps = chapter.sentences.flatMap { $0.wordTimestamps }
        return allTimestamps.last(where: { playbackTime >= $0.time })
    }

    var currentChapter: Chapter? {
        get {
            guard let story = currentStory else {
                return nil
            }
            return story.chapters[safe: story.currentChapterIndex]
        }
        set(newChapter) {
            if let index = currentStory?.currentChapterIndex,
               let newChapter {
                var newStory = currentStory
                newStory?.chapters[index] = newChapter
                currentStory = newStory
            }
        }
    }

    var currentSentence: Sentence? {
        get {
            guard let sentenceIndex = currentStory?.currentSentenceIndex else {
                return nil
            }
            return currentChapter?.sentences[safe: sentenceIndex]
        }
        set(newSentence) {
            if let index = currentStory?.currentSentenceIndex,
               let newSentence {
                var newChapter = currentChapter
                newChapter?.sentences[index] = newSentence
                currentChapter = newChapter
            }
        }
    }

    var currentChapterAudioData: Data? {
        currentChapter?.audioData
    }

    var isCreatingChapter: Bool {
        readerDisplayType != .normal
    }

    var shouldSelectNewCurrentStory: Bool {
        let isCurrentStoryInMemory = savedStories.contains(where: { $0.id == currentStory?.id })
        return currentStory == nil || !isCurrentStoryInMemory
    }

    mutating func updateAudioPlayer(_ data: Data?) {
        audioPlayer = data?.createAVPlayer() ?? AVPlayer()
    }

    var isPlaybackAtEnd: Bool {
        let currentTime = audioPlayer.currentTime().seconds

        guard let chapter = currentChapter,
              !chapter.sentences.isEmpty,
              let lastSentence = chapter.sentences.last,
              !lastSentence.wordTimestamps.isEmpty,
              let lastWord = lastSentence.wordTimestamps.last else {
            return false
        }

        let endTime = lastWord.time + lastWord.duration - 0.5

        return currentTime >= endTime
    }
}
