//
//  TextPracticeState.swift
//  TextPractice
//
//  Created by Isaac Akalanne on 02/09/2025.
//

import TextGeneration
import Study

struct TextPracticeState: Equatable {
    var isShowingOriginalSentence = false
    var chapter: Chapter?
    var definitions: [Definition] = []
    var selectedDefinition: Definition?
    var viewState: TextPracticeViewState = .normal
}
