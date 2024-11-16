//
//  FastChineseState.swift
//  FastChinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import AVKit

struct FastChineseState {
    var isShowingCreateStoryScreen = false
    var isShowingSettingsScreen = false
    var isShowingStoryListView = false
    var viewState: ViewState = .normal

    var selectedGenres: [Genre] = []
    var selectedStorySetting: StorySetting?

    var settingsState = SettingsState()
    var storyState = StoryState()
    var audioState = AudioState()

    var definitionViewId = UUID()
    var chapterViewId = UUID()
    var translationViewId = UUID()

    var currentSpokenWord: WordTimeStampData? {
        storyState.currentChapter?.timestampData.last(where: { audioState.currentPlaybackTime >= $0.time })
    }

    var tappedWord: WordTimeStampData?
    var currentDefinition: Definition?
}

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

struct DefinitionState {

}

struct AudioState {
    var audioPlayer = AVPlayer()
    var currentPlaybackTime: TimeInterval = 0
    var isPlayingAudio = false

    init(audioPlayer: AVPlayer = AVPlayer(),
         currentPlaybackTime: TimeInterval = 0,
         isPlayingAudio: Bool = false) {
        self.audioPlayer = audioPlayer
        self.currentPlaybackTime = currentPlaybackTime
        self.isPlayingAudio = isPlayingAudio
    }
}
