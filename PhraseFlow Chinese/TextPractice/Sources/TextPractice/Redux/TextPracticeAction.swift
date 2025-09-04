//
//  TextPracticeAction.swift
//  TextPractice
//
//  Created by Isaac Akalanne on 02/09/2025.
//

import TextGeneration
import Study

public enum TextPracticeAction: Sendable {
    case setChapter(Chapter?)
    case addDefinitions([Definition])
}
