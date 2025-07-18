//
//  FlowTaleRepositoryProtocol.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import Foundation
import StoreKit
import TextGeneration
import Settings

protocol SpeechRepositoryProtocol {
    func synthesizeSpeech(_ chapter: Chapter,
                          voice: Voice,
                          language: Language) async throws -> (Chapter, Int)
}
