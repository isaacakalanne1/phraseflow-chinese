//
//  TextPracticeState.swift
//  TextPractice
//
//  Created by Isaac Akalanne on 02/09/2025.
//

import TextGeneration
import Settings
import Study

struct TextPracticeState: Equatable {
    var isShowingOriginalSentence = false
    var isWritingNewChapter = false
    var isPlayingChapterAudio = false
    var isViewingLastChapter = false
    
    var settings = SettingsState()
    var chapter: Chapter
    var definitions: [DefinitionKey: Definition] = [:]
    var selectedDefinition: Definition?
    var viewState: TextPracticeViewState = .normal
    var textPracticeType: TextPracticeType
}
