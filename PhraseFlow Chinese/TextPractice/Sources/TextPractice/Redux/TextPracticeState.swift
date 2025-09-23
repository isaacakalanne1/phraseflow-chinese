//
//  TextPracticeState.swift
//  TextPractice
//
//  Created by Isaac Akalanne on 02/09/2025.
//

import TextGeneration
import Settings
import Study
import AVKit

public struct TextPracticeState: Equatable {
    var isShowingOriginalSentence: Bool
    var isWritingNewChapter: Bool
    var isPlayingChapterAudio: Bool
    var isViewingLastChapter: Bool
    
    var chapterAudioPlayer: AVPlayer
    var settings: SettingsState
    var chapter: Chapter
    var definitions: [DefinitionKey: Definition]
    var selectedDefinition: Definition?
    var viewState: TextPracticeViewState
    var textPracticeType: TextPracticeType
    
    public init(
        isShowingOriginalSentence: Bool = false,
        isWritingNewChapter: Bool = false,
        isPlayingChapterAudio: Bool = false,
        isViewingLastChapter: Bool = false,
        chapterAudioPlayer: AVPlayer = .init(),
        settings: SettingsState = SettingsState(),
        chapter: Chapter = .init(),
        definitions: [DefinitionKey : Definition] = [:],
        selectedDefinition: Definition? = nil,
        viewState: TextPracticeViewState = .normal,
        textPracticeType: TextPracticeType = .story
    ) {
        self.isShowingOriginalSentence = isShowingOriginalSentence
        self.isWritingNewChapter = isWritingNewChapter
        self.isPlayingChapterAudio = isPlayingChapterAudio
        self.isViewingLastChapter = isViewingLastChapter
        self.chapterAudioPlayer = chapterAudioPlayer
        self.settings = settings
        self.chapter = chapter
        self.definitions = definitions
        self.selectedDefinition = selectedDefinition
        self.viewState = viewState
        self.textPracticeType = textPracticeType
    }
    
    public func isNearEndOfTrack(endTimeOfLastWord: Double) -> Bool {
        chapterAudioPlayer.currentTime().seconds >= endTimeOfLastWord
    }
    
    public func getCurrentPlaybackTime() -> Double {
        chapterAudioPlayer.currentTime().seconds
    }
}
