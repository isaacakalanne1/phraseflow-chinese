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
    func fetchSavedPhrases() throws -> [Sentence]
    func saveSentences(_ phrases: [Sentence]) throws
    func unsavePhrase(_ phrase: Sentence)
    func saveAudioToTempFile(fileName: String, data: Data) throws -> URL
}

class FastChineseDataStore: FastChineseDataStoreProtocol {

    func fetchSavedPhrases() throws -> [Sentence] {
        do {
            if let savedData = UserDefaults.standard.data(forKey: "sentencesKey") {
                let phrases = try JSONDecoder().decode([Sentence].self, from: savedData)
                return phrases.shuffled()
            }
        } catch {
            throw FastChineseDataStoreError.failedToDecodePhrases
        }
        return []
    }

    func saveSentences(_ phrases: [Sentence]) throws {
        let encodedData = try JSONEncoder().encode(phrases)
        UserDefaults.standard.set(encodedData, forKey: "sentencesKey")
    }

    func unsavePhrase(_ phrase: Sentence) {
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
