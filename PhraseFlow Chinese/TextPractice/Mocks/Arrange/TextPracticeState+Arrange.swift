//
//  TextPracticeState+Arrange.swift
//  TextPractice
//
//  Created by Isaac Akalanne on 21/09/2025.
//

import Foundation
import Settings
import SettingsMocks
import Study
import TextGeneration
import TextGenerationMocks
import TextPractice

public extension TextPracticeState {
    static var arrange: TextPracticeState {
        .arrange()
    }
    
    static func arrange(
        isShowingOriginalSentence: Bool = false,
        isWritingNewChapter: Bool = false,
        isPlayingChapterAudio: Bool = false,
        isViewingLastChapter: Bool = false,
        settings: SettingsState = .arrange,
        chapter: Chapter = .arrange,
        definitions: [DefinitionKey: Definition] = [:],
        selectedDefinition: Definition? = nil,
        viewState: TextPracticeViewState = .normal,
        textPracticeType: TextPracticeType = .story
    ) -> TextPracticeState {
        .init(
            isShowingOriginalSentence: isShowingOriginalSentence,
            isWritingNewChapter: isWritingNewChapter,
            isPlayingChapterAudio: isPlayingChapterAudio,
            isViewingLastChapter: isViewingLastChapter,
            settings: settings,
            chapter: chapter,
            definitions: definitions,
            selectedDefinition: selectedDefinition,
            viewState: viewState,
            textPracticeType: textPracticeType
        )
    }
}
