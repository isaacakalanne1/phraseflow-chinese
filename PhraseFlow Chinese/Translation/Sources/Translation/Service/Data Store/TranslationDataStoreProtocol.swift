//
//  TranslationDataStoreProtocol.swift
//  Translation
//
//  Created by Isaac Akalanne on 20/07/2025.
//

import Combine
import Foundation
import TextGeneration

protocol TranslationDataStoreProtocol {
    func saveTranslation(_ chapter: Chapter) throws
    func loadTranslationHistory() throws -> [Chapter]
    func deleteTranslation(id: UUID) throws
    func cleanupOrphanedTranslationFiles() throws
}