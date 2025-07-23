//
//  StoryEnvironment.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import Combine
import Loading
import TextGeneration

public struct StoryEnvironment: StoryEnvironmentProtocol {
    public let storySubject = CurrentValueSubject<UUID?, Never>(nil)
    public let loadingSubject: CurrentValueSubject<LoadingStatus?, Never> = .init(nil)
    
    public init() {}
    
    public func selectChapter(storyId: UUID) {
        storySubject.send(storyId)
    }
    
    func generateChapter(previousChapters: [Chapter],
                         deviceLanguage: Language?,
                         currentSubscription: SubscriptionLevel?) async throws -> Chapter {
        loadingSubject.send(.writing)

        var newChapter = try await service.generateChapter(previousChapters: previousChapters,
                                                           deviceLanguage: deviceLanguage)
        loadingSubject.send(.generatingImage)

        if newChapter.imageData == nil,
           !newChapter.passage.isEmpty {
            if let firstChapter = previousChapters.first, let existingImageData = firstChapter.imageData {
                newChapter.imageData = existingImageData
            } else {
                newChapter.imageData = try await service.generateImage(with: newChapter.passage)
            }
        }
        loadingSubject.send(.generatingSpeech)

        let voiceToUse = newChapter.audioVoice
        let (processedChapter, ssmlCharacterCount) = try await synthesizeSpeechWithCharacterCount(
            newChapter,
            voice: voiceToUse,
            language: newChapter.language
        )

        try trackSSMLCharacterUsage(
            characterCount: ssmlCharacterCount,
            subscription: currentSubscription
        )

        chapterSubject.send(processedChapter)
        loadingSubject.send(.complete)
        return processedChapter
    }

    func generateFirstChapter(language: Language,
                              difficulty: Difficulty,
                              voice: Voice,
                              deviceLanguage: Language?,
                              storyPrompt: String?,
                              currentSubscription: SubscriptionLevel?) async throws -> Chapter {
        loadingSubject.send(.writing)

        var newChapter = try await service.generateFirstChapter(language: language,
                                                               difficulty: difficulty,
                                                               voice: voice,
                                                               deviceLanguage: deviceLanguage,
                                                               storyPrompt: storyPrompt)
        loadingSubject.send(.generatingImage)

        if newChapter.imageData == nil,
           !newChapter.passage.isEmpty {
            newChapter.imageData = try await service.generateImage(with: newChapter.passage)
        }
        loadingSubject.send(.generatingSpeech)

        let voiceToUse = newChapter.audioVoice
        let (processedChapter, ssmlCharacterCount) = try await synthesizeSpeechWithCharacterCount(
            newChapter,
            voice: voiceToUse,
            language: newChapter.language
        )

        try trackSSMLCharacterUsage(
            characterCount: ssmlCharacterCount,
            subscription: currentSubscription
        )

        chapterSubject.send(processedChapter)
        loadingSubject.send(.complete)
        return processedChapter
    }

    // MARK: Chapters

    func saveChapter(_ chapter: Chapter) throws {
        var chapterToSave = chapter
        
        // Only save cover art in the first chapter to save memory
        let allChapters = try dataStore.loadAllChapters(for: chapter.storyId)
        let isFirstChapter = allChapters.isEmpty || allChapters.allSatisfy { $0.id == chapter.id }
        
        if !isFirstChapter {
            chapterToSave.imageData = nil
        }
        
        try dataStore.saveChapter(chapterToSave)
    }
}
