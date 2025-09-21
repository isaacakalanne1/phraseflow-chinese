//
//  TextGenerationServices.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import APIRequest
import Settings
import Foundation

enum TextGenerationServicesError: Error {
    case failedToGetDeviceLanguage
    case failedToGetResponseData
    case failedToDecodeSentences
}

public class TextGenerationServices: TextGenerationServicesProtocol {

    public init() {}

    public func generateChapterStory(
        previousChapters: [Chapter],
        language: Language?,
        difficulty: Difficulty?,
        voice: Voice?,
        storyPrompt: String?
    ) async throws -> Chapter {
        let isFirstChapter = previousChapters.isEmpty
        
        if isFirstChapter {
            guard let language = language,
                  let difficulty = difficulty,
                  let voice = voice else {
                throw NSError(domain: "TextGenerationServices", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing required parameters for first chapter"])
            }
            
            let baseChapter = Chapter(
                storyId: UUID(),
                title: "",
                sentences: [],
                audioVoice: voice,
                audio: ChapterAudio(data: Data()),
                passage: "",
                difficulty: difficulty,
                deviceLanguage: Language.deviceLanguage,
                language: language,
                storyPrompt: storyPrompt
            )
            
            let storyText = try await generateStoryRequest(baseChapter: baseChapter, previousChapters: [])
            
            var newChapter = baseChapter
            newChapter.id = UUID()
            newChapter.passage = storyText
            newChapter.lastUpdated = .now
            return newChapter
        } else {
            guard let baseChapter = previousChapters.last else {
                throw TextGenerationServicesError.failedToGetResponseData
            }
            
            let storyText = try await generateStoryRequest(baseChapter: baseChapter, previousChapters: previousChapters)
            
            var newChapter = baseChapter
            newChapter.id = UUID()
            newChapter.passage = storyText
            newChapter.lastUpdated = .now
            return newChapter
        }
    }

    public func formatStoryIntoSentences(
        chapter: Chapter,
        deviceLanguage: Language?
    ) async throws -> Chapter {
        do {
            guard let deviceLanguage else {
                throw TextGenerationServicesError.failedToGetDeviceLanguage
            }
            
            let jsonString = try await formatSentencesRequest(chapter: chapter, deviceLanguage: deviceLanguage)
            guard let jsonData = jsonString.data(using: .utf8) else {
                throw TextGenerationServicesError.failedToGetResponseData
            }
            
            let decoder = JSONDecoder.createChapterResponseDecoder(deviceLanguageKey: deviceLanguage.rawValue, targetLanguageKey: chapter.language.rawValue)
            let chapterResponse = try decoder.decode(ChapterResponse.self, from: jsonData)
            
            var updatedChapter = chapter
            updatedChapter.title = chapterResponse.chapterNumberAndTitle ?? ""
            updatedChapter.sentences = chapterResponse.sentences
            updatedChapter.chapterSummary = chapterResponse.briefLatestStorySummary
            
            if let title = chapterResponse.titleOfNovel {
                updatedChapter.storyTitle = title
            }
            
            return updatedChapter
        } catch {
            throw TextGenerationServicesError.failedToDecodeSentences
        }
    }

    private func generateStoryRequest(
        baseChapter: Chapter,
        previousChapters: [Chapter]
    ) async throws -> String {
        var messages: [[String: String]] = []
        
        let isFirstChapter = previousChapters.isEmpty
        
        if isFirstChapter {
            var initialPrompt = """
            Write an incredible first chapter of a story written in \(baseChapter.language.descriptiveEnglishName).
            
            """
            
            if let storyPrompt = baseChapter.storyPrompt {
                let settingPrompt = "The story is in the following setting: \(storyPrompt)\n\n"
                initialPrompt.append(settingPrompt)
            }

            let promptDetails = """
            \(baseChapter.difficulty.vocabularyPrompt).
            Use a vocabulary of around 150 \(baseChapter.language.descriptiveEnglishName) words.
            The chapter should be around 400 \(baseChapter.language.descriptiveEnglishName) words long.
            
            Write only the story text in \(baseChapter.language.descriptiveEnglishName), without any formatting or sentence breaks.
            """
            initialPrompt.append(promptDetails)
            
            messages.append(["role": "user", "content": initialPrompt])
        } else {
            // Add conversation history from previous chapters
            for (index, chapter) in previousChapters.enumerated() {
                if index == 0 {
                    // First chapter as system context
                    let systemMessage = """
                    Story Title: \(chapter.storyTitle)
                    Chapter \(index + 1): \(chapter.title)
                    
                    \(chapter.passage)
                    """
                    messages.append(["role": "system", "content": systemMessage])
                } else {
                    // Previous chapters as assistant responses
                    let assistantMessage = """
                    Chapter \(index + 1): \(chapter.title)
                    
                    \(chapter.passage)
                    """
                    messages.append(["role": "assistant", "content": assistantMessage])
                }
            }
            
            // Next chapter prompt
            var nextChapterPrompt = """
            Continue the story by writing the next chapter in \(baseChapter.language.descriptiveEnglishName).
            
            """
            
            if let storyPrompt = baseChapter.storyPrompt {
                let settingPrompt = "Remember the story setting: \(storyPrompt)\n\n"
                nextChapterPrompt.append(settingPrompt)
            }

            let promptDetails = """
            \(baseChapter.difficulty.vocabularyPrompt).
            Use a vocabulary of around 150 \(baseChapter.language.descriptiveEnglishName) words.
            The chapter should be around 400 \(baseChapter.language.descriptiveEnglishName) words long.
            Build upon the previous chapters to continue the narrative in an engaging way.
            
            Write only the story text in \(baseChapter.language.descriptiveEnglishName), without any formatting or sentence breaks.
            """
            nextChapterPrompt.append(promptDetails)
            
            messages.append(["role": "user", "content": nextChapterPrompt])
        }
        
        let requestBody: [String: Any] = ["messages": messages]

        return try await RequestFactory.makeRequest(type: .openRouter(.geminiFlash),
                                                    requestBody: requestBody)
    }

    private func formatSentencesRequest(
        chapter: Chapter,
        deviceLanguage: Language
    ) async throws -> String {
        let isFirstChapter = chapter.storyTitle.isEmpty
        
        let prompt = """
        Take the following story text in \(chapter.language.descriptiveEnglishName) and break it into individual sentences with translations to \(deviceLanguage.descriptiveEnglishName):
        
        \(chapter.passage)
        
        Please format this into proper sentences with appropriate translations.
        """
        
        let messages: [[String: String]] = [
            ["role": "user", "content": prompt]
        ]
        
        var requestBody: [String: Any] = ["messages": messages]
        requestBody["response_format"] = sentenceSchema(originalLanguage: deviceLanguage,
                                                        translationLanguage: chapter.language,
                                                        shouldCreateTitle: isFirstChapter)

        return try await RequestFactory.makeRequest(type: .openRouter(.geminiFlash),
                                                    requestBody: requestBody)
    }
}
