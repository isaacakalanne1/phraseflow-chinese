//
//  Definition+Arrange.swift
//  Study
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Foundation
import Settings
import Study
import TextGeneration
import TextGenerationMocks

public extension Definition {
    static var arrange: Definition {
        .arrange()
    }
    
    static func arrange(
        id: UUID = UUID(),
        creationDate: Date = Date(),
        studiedDates: [Date] = [],
        timestampData: WordTimeStampData = .arrange,
        sentence: Sentence = .arrange,
        detail: WordDefinition = .arrange,
        language: Language = .spanish,
        hasBeenSeen: Bool = false,
        sentenceId: UUID = UUID(),
        storyId: UUID = UUID(),
        audioData: Data? = nil
    ) -> Definition {
        .init(
            id: id,
            creationDate: creationDate,
            studiedDates: studiedDates,
            timestampData: timestampData,
            sentence: sentence,
            detail: detail,
            language: language,
            hasBeenSeen: hasBeenSeen,
            sentenceId: sentenceId,
            storyId: storyId,
            audioData: audioData
        )
    }
}
