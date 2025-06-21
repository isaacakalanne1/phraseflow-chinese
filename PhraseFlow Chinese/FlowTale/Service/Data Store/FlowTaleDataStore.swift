//
//  FlowTaleDataStore.swift
//  FlowTale
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import Security
import Combine

class FlowTaleDataStore: FlowTaleDataStoreProtocol {
    private let fileManager = FileManager.default

    private let storyDataStore = StoryDataStore()
    private let definitionDataStore = DefinitionDataStore()
    private let userLimitsDataStore = UserLimitsDataStore()
    private let settingsDataStore = SettingsDataStore()

    private var documentsDirectory: URL? {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    public var chapterSubject: CurrentValueSubject<Chapter?, Never> {
        storyDataStore.chapterSubject
    }

    func saveChapter(_ chapter: Chapter) throws {
        try storyDataStore.saveChapter(chapter)
    }

    func loadAllChapters() throws -> [Chapter] {
        try storyDataStore.loadAllChapters()
    }
    
    func deleteChapter(_ chapter: Chapter) throws {
        try storyDataStore.deleteChapter(chapter)
    }

    func loadAllChapters(for storyId: UUID) throws -> [Chapter] {
        try storyDataStore.loadAllChapters(for: storyId)
    }

    func loadDefinitions() throws -> [Definition] {
        try definitionDataStore.loadDefinitions()
    }

    func saveDefinitions(_ definitions: [Definition]) throws {
        try definitionDataStore.saveDefinitions(definitions)
    }

    func deleteDefinition(with id: UUID) throws {
        try definitionDataStore.deleteDefinition(with: id)
    }

    func cleanupOrphanedDefinitionFiles() throws {
        try definitionDataStore.cleanupOrphanedDefinitionFiles()
    }

    func saveSentenceAudio(_ audioData: Data, id: UUID) throws {
        try definitionDataStore.saveSentenceAudio(audioData, id: id)
    }

    func loadSentenceAudio(id: UUID) throws -> Data {
        try definitionDataStore.loadSentenceAudio(id: id)
    }

    func cleanupOrphanedSentenceAudioFiles() throws {
        try definitionDataStore.cleanupOrphanedSentenceAudioFiles()
    }

    func trackSSMLCharacterUsage(characterCount: Int, subscription: SubscriptionLevel?) throws {
        try userLimitsDataStore.trackSSMLCharacterUsage(
            characterCount: characterCount,
            subscription: subscription
        )
    }

    func loadAppSettings() throws -> SettingsState {
        try settingsDataStore.loadAppSettings()
    }

    func saveAppSettings(_ settings: SettingsState) throws {
        try settingsDataStore.saveAppSettings(settings)
    }
}
