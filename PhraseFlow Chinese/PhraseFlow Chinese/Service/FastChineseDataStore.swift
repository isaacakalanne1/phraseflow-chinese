//
//  FastChineseDataStore.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation

enum FastChineseDataStoreError: Error {
    case failedToSaveAudio
}

protocol FastChineseDataStoreProtocol {
    func fetchLearningPhrases(category: PhraseCategory) -> [Phrase]
    func saveAudioToTempFile(fileName: String, data: Data) throws -> URL
}

class FastChineseDataStore: FastChineseDataStoreProtocol {

    func fetchLearningPhrases(category: PhraseCategory) -> [Phrase] {
        if let savedShortData = UserDefaults.standard.data(forKey: category.storageKey),
           let phrases = try? JSONDecoder().decode([Phrase].self, from: savedShortData) {
            return phrases.shuffled()
        }
        return []
    }

    func saveAudioToTempFile(fileName: String, data: Data) throws -> URL {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName).wav")
        do {
            try data.write(to: tempURL)
        } catch {
            throw FastChineseDataStoreError.failedToSaveAudio
        }
        return tempURL
    }

}
