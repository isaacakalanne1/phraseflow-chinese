//
//  FastChineseEnvironment.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation

protocol FastChineseEnvironmentProtocol {
    var service: FastChineseServicesProtocol { get }
    var dataStore: FastChineseDataStoreProtocol { get }

    func fetchAllPhrases(gid: String) async throws -> [Phrase]
    func fetchLearningPhrases(category: PhraseCategory) -> [Phrase]
}

struct FastChineseEnvironment: FastChineseEnvironmentProtocol {

    let service: FastChineseServicesProtocol
    let dataStore: FastChineseDataStoreProtocol

    init() {
        self.service = FastChineseServices()
        self.dataStore = FastChineseDataStore()
    }

    func fetchAllPhrases(gid: String) async throws -> [Phrase] {
        try await service.fetchAllPhrases(gid: gid)
    }

    func fetchLearningPhrases(category: PhraseCategory) -> [Phrase] {
        dataStore.fetchLearningPhrases(category: category)
    }
}
