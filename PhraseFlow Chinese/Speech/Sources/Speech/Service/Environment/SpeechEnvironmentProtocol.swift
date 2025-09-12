//
//  SpeechEnvironmentProtocol.swift
//  Speech
//
//  Created by iakalann on 18/07/2025.
//

import Combine
import Foundation
import TextGeneration
import Settings
import UserLimit

public protocol SpeechEnvironmentProtocol {
    var synthesizedCharactersSubject: CurrentValueSubject<Int?, Never> { get }
    var speechRepository: SpeechRepositoryProtocol { get }
    
    func synthesizeSpeech(for chapter: Chapter, voice: Voice, language: Language) async throws -> Chapter
}
