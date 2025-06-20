//
//  FlowTaleEnvironmentProtocol.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import Combine
import Foundation
import StoreKit

protocol FlowTaleEnvironmentProtocol {
    var dataStore: FlowTaleDataStoreProtocol { get }
    var loadingSubject: CurrentValueSubject<LoadingState?, Never> { get }
    var storySubject: CurrentValueSubject<Story?, Never> { get }

    func synthesizeSpeech(for chapter: Chapter,
                          story: Story,
                          voice: Voice,
                          language: Language) async throws -> Chapter
    func getProducts() async throws -> [Product]
    func generateStory(story: Story,
                       voice: Voice,
                       deviceLanguage: Language?,
                       currentSubscription: SubscriptionLevel?) async throws -> Story

    func loadDefinitions() throws -> [Definition]
    func saveDefinitions(_ definitions: [Definition]) throws
    func deleteDefinition(with id: UUID) throws

    func saveSentenceAudio(_ audioData: Data, id: UUID) throws
    func loadSentenceAudio(id: UUID) throws -> Data

    func loadAppSettings() throws -> SettingsState
    func saveAppSettings(_ settings: SettingsState) throws

    // Stories & Chapters
    func saveStory(_ story: Story) throws
    func loadAllStories() throws -> [Story]
    func unsaveStory(_ story: Story) throws

    func loadAllChapters(for storyId: UUID) throws -> [Chapter]

    func fetchDefinitions(in sentence: Sentence?,
                          story: Story,
                          deviceLanguage: Language) async throws -> [Definition]
    func purchase(_ product: Product) async throws
    func validateReceipt()
    func moderateText(_ text: String) async throws -> ModerationResponse
    
    // Translation functionality
    func translateText(
        _ text: String,
        from sourceLanguage: Language?,
        to targetLanguage: Language
    ) async throws -> Chapter
    
    func breakdownText(
        _ text: String,
        textLanguage: Language,
        deviceLanguage: Language
    ) async throws -> Chapter
}
