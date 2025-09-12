//
//  SpeechEnvironment.swift
//  Speech
//
//  Created by iakalann on 18/07/2025.
//

import Combine
import Foundation
import TextGeneration
import Settings

public struct SpeechEnvironment: SpeechEnvironmentProtocol {
    public var synthesizedCharactersSubject: CurrentValueSubject<Int?, Never>
    public let speechRepository: SpeechRepositoryProtocol
    
    public init(speechRepository: SpeechRepositoryProtocol) {
        synthesizedCharactersSubject = .init(nil)
        self.speechRepository = speechRepository
    }
    
    public func synthesizeSpeech(for chapter: Chapter, voice: Voice, language: Language) async throws -> Chapter {
        let (processedChapter, _) = try await speechRepository.synthesizeSpeech(chapter, voice: voice, language: language)
        
        let characterCount = speechRepository.createSpeechSsml(chapter: chapter, voice: voice).count
        synthesizedCharactersSubject.send(characterCount)
        return processedChapter
    }
}
