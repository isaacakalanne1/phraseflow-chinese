//
//  FastChineseDataStore.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation

protocol FastChineseDataStoreProtocol {
    func fetchLearningPhrases(category: PhraseCategory) -> [Phrase]
}

class FastChineseDataStore: FastChineseDataStoreProtocol {

    func fetchLearningPhrases(category: PhraseCategory) -> [Phrase] {
        if let savedShortData = UserDefaults.standard.data(forKey: category.storageKey),
           let phrases = try? JSONDecoder().decode([Phrase].self, from: savedShortData) {
            return phrases.shuffled()
        }
        return []
    }

}
