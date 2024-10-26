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
    var chapterIndex = 0
    var sentenceIndex = 0
    var isShowingCreateStoryScreen = false
    var isShowingSettingsScreen = false
    var isShowingStoryListView = false
    var viewState: ViewState = .normal

    var selectedCategories: [Category] = []
    var selectedSubjects: [Subject] = []

    var currentPlaybackTime: TimeInterval = 0

    var currentChapter: Chapter? {
        guard let currentStory,
           currentStory.chapters.count > chapterIndex else {
            return nil
        }
        return currentStory.chapters[chapterIndex]
    }

    var currentSentence: Sentence? {
        if let currentChapter,
           currentChapter.sentences.count > sentenceIndex {
            return currentChapter.sentences[sentenceIndex]
        }
        return nil
    }

    var selectedWordStartIndex = 0
    var selectedWordEndIndex = 0

    var speechSpeed: SpeechSpeed = .normal
    var characterToDefine: String = ""
    var currentDefinition: Definition?

    var isShowingPinyin = true
    var isShowingEnglish = true
    var isShowingMandarin = true
    var audioPlayer = try? AVAudioPlayer(data: Data())
    var timestampData: [WordTimeStampData] = []

    var isPlayingAudio = false

    func getSpokenWord(sentenceIndex: Int, characterIndex: Int) -> WordTimeStampData? {
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
