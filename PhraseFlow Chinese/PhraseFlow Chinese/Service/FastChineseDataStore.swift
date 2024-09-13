//
//  FastChineseDataStore.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation

enum FastChineseDataStoreError: Error {
    case failedToSaveAudio
    case failedToDecodePhrases
}

protocol FastChineseDataStoreProtocol {
    func fetchSavedPhrases() throws -> [Phrase]
    func saveAllPhrases(_ phrases: [Phrase]) throws
    func unsavePhrase(_ phrase: Phrase)
    func saveAudioToTempFile(fileName: String, data: Data) throws -> URL
}

class FastChineseDataStore: FastChineseDataStoreProtocol {

    func fetchSavedPhrases() throws -> [Phrase] {
        do {
            if let savedData = UserDefaults.standard.data(forKey: "allPhrasesKey") {
                let phrases = try JSONDecoder().decode([Phrase].self, from: savedData)
                return phrases.shuffled()
            }
        } catch {
            throw FastChineseDataStoreError.failedToDecodePhrases
        }
        return []
    }

    func saveAllPhrases(_ phrases: [Phrase]) throws {
        let encodedData = try JSONEncoder().encode(phrases)
        UserDefaults.standard.set(encodedData, forKey: "allPhrasesKey")
    }

    func unsavePhrase(_ phrase: Phrase) {
        UserDefaults.standard.removeObject(forKey: phrase.mandarin)
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
