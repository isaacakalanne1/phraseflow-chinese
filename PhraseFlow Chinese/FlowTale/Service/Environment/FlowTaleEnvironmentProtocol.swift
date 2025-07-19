//
//  FlowTaleEnvironmentProtocol.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import Audio
import Combine
import Foundation
import StoreKit
import Story
import Settings
import Moderation
import Definition
import SnackBar
import Translation
import Speech

// IGNORE: THIS WILL BE DELETED SOON
protocol FlowTaleEnvironmentProtocol {
    var loadingSubject: CurrentValueSubject<LoadingStatus?, Never> { get }
    var chapterSubject: CurrentValueSubject<Chapter?, Never> { get }
    var storyEnvironment: StoryEnvironmentProtocol { get }
    var audioEnvironment: AudioEnvironmentProtocol { get }
    var settingsEnvironment: SettingsEnvironmentProtocol { get }
    var moderationEnvironment: ModerationEnvironmentProtocol { get }
    var snackBarEnvironment: SnackBarEnvironmentProtocol { get }
    var definitionEnvironment: DefinitionEnvironmentProtocol { get }
    var translationEnvironment: TranslationEnvironmentProtocol { get }
    var speechEnvironment: SpeechEnvironmentProtocol { get }

    func synthesizeSpeech(for chapter: Chapter,
                          voice: Voice,
                          language: Language) async throws -> Chapter
    func getProducts() async throws -> [Product]
    func generateChapter(previousChapters: [Chapter],
                         deviceLanguage: Language?,
                         currentSubscription: SubscriptionLevel?) async throws -> Chapter
    func generateFirstChapter(language: Language,
                              difficulty: Difficulty,
                              voice: Voice,
                              deviceLanguage: Language?,
                              storyPrompt: String?,
                              currentSubscription: SubscriptionLevel?) async throws -> Chapter

    func loadDefinitions() throws -> [Definition]
    func saveDefinitions(_ definitions: [Definition]) throws
    func deleteDefinition(with id: UUID) throws

    func saveSentenceAudio(_ audioData: Data, id: UUID) throws
    func loadSentenceAudio(id: UUID) throws -> Data

    func loadAppSettings() throws -> SettingsState
    func saveAppSettings(_ settings: SettingsState) throws

    // Chapters only
    func saveChapter(_ chapter: Chapter) throws
    func loadAllChapters() throws -> [Chapter]
    func deleteChapter(_ chapter: Chapter) throws

    func fetchDefinitions(in sentence: Sentence?,
                          chapter: Chapter,
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
