//
//  FlowTaleDataStoreProtocol.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import Combine
import Foundation

protocol FlowTaleDataStoreProtocol {
    var storySubject: CurrentValueSubject<Story?, Never> { get }
    var definitionsSubject: CurrentValueSubject<[Definition]?, Never> { get }

    // Settings
    func loadAppSettings() throws -> SettingsState
    func saveAppSettings(_ settings: SettingsState) throws

    // Definitions
    func loadDefinitions() throws -> [Definition]
    func saveDefinitions(_ definitions: [Definition]) throws
    func deleteDefinition(with id: UUID) throws
    func cleanupOrphanedDefinitionFiles() throws

    // Sentence Audio
    func saveSentenceAudio(_ audioData: Data, id: UUID) throws
    func loadSentenceAudio(id: UUID) throws -> Data
    func cleanupOrphanedSentenceAudioFiles() throws

    // Stories & Chapters
    func saveStory(_ story: Story) throws
    func loadAllStories() throws -> [Story]

    // Chapters
    func saveChapter(_ chapter: Chapter, storyId: UUID, chapterIndex: Int) throws
    func loadAllChapters(for storyId: UUID) throws -> [Chapter]

    // Remove entire story (and its chapters) from disk
    func unsaveStory(_ story: Story) throws
    
    // Track SSML character usage for subscription limits
    func trackSSMLCharacterUsage(characterCount: Int, subscription: SubscriptionLevel?) throws
}
