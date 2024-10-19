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

    var selectedCategories: [Category] = []
    var selectedSubjects: [Subject] = []

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
    var timestampData: [(word: String,
                         time: Double,
                         textOffset: Int,
                         wordLength: Int)] = []
}
