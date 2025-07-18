//
//  SpeechEnvironment.swift
//  Speech
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import TextGeneration
import Settings

struct SpeechEnvironment: SpeechEnvironmentProtocol {
    let speechRepository: SpeechRepositoryProtocol
    
    func synthesizeSpeech(for chapter: Chapter, voice: Voice, language: Language) async throws -> Chapter {
        let (processedChapter, _) = try await speechRepository.synthesizeSpeech(chapter, voice: voice, language: language)
        return processedChapter
    }
    
    func synthesizeSpeechWithCharacterCount(for chapter: Chapter, voice: Voice, language: Language) async throws -> (Chapter, Int) {
        return try await speechRepository.synthesizeSpeech(chapter, voice: voice, language: language)
    }
}