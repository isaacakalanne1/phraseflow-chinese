//
//  FastChineseState.swift
//  FastChinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import AVKit

struct FastChineseState {
    var currentStory: Story?
    var savedStories: [Story] = []
    var sentenceIndex = 0
    var isShowingCreateStoryScreen = false
    var isShowingSettingsScreen = false
    var isShowingStoryListView = false
    var viewState: ViewState = .normal

    var selectedCategories: [Category] = []

    var currentPlaybackTime: TimeInterval = 0

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

    var speechSpeed: SpeechSpeed = .normal
    var currentDefinition: Definition?

    var isShowingPinyin = true
    var isShowingEnglish = true
    var isShowingDefinition = true
    var audioPlayer = try? AVAudioPlayer(data: Data())
    var timestampData: [WordTimeStampData]? {
        currentChapter?.timestampData
    }

    var definitionViewId = UUID()
    var chapterViewId = UUID()

    var isPlayingAudio = false

    var currentSpokenWord: WordTimeStampData? {
        timestampData?.last(where: { currentPlaybackTime >= $0.time })
//        guard let word = timestampData?.last(where: { currentPlaybackTime >= $0.time }) else { return nil }
//        if word.time + word.duration < currentPlaybackTime,
//           let index = timestampData?.firstIndex(of: word),
//           let followingWord = timestampData?[safe: index + 1] {
//            return followingWord
//        }
//        return word
    }

    var tappedWord: WordTimeStampData?

    func getSpokenWord(sentenceIndex: Int, characterIndex: Int) -> WordTimeStampData? {
        guard let timestampData else {
            return nil
        }
        // Calculate the overall character index
        var totalCharacterIndex = 0
        guard let currentChapter else { return nil }

        for (index, sentence) in currentChapter.sentences.enumerated() {
            let sentenceLength = sentence.mandarin.count

            if index < sentenceIndex {
                // Sum up the lengths of previous sentences
                totalCharacterIndex += sentenceLength
            } else if index == sentenceIndex {
                // Add the characterIndex within the current sentence
                totalCharacterIndex += characterIndex
                break
            } else {
                break
            }
        }

        // Now totalCharacterIndex is the overall index of the character
        // Find the SpokenWord in timestampData that includes this index
        return timestampData.last(where: { totalCharacterIndex >= $0.textOffset})
    }
}
