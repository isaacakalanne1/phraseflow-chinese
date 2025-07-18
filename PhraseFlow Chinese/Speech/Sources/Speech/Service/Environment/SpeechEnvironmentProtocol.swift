//
//  SpeechEnvironmentProtocol.swift
//  Speech
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import TextGeneration
import Settings

protocol SpeechEnvironmentProtocol {
    var speechRepository: SpeechRepositoryProtocol { get }
    
    func synthesizeSpeech(for chapter: Chapter, voice: Voice, language: Language) async throws -> Chapter
    func synthesizeSpeechWithCharacterCount(for chapter: Chapter, voice: Voice, language: Language) async throws -> (Chapter, Int)
}