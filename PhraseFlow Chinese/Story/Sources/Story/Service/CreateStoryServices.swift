//
//  CreateStoryServices.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation

class CreateStoryServices: CreateStoryServicesProtocol {

    func generateFirstChapter(language: Language, difficulty: Difficulty, voice: Voice, deviceLanguage: Language?, storyPrompt: String?) async throws -> Chapter {
        do {
            guard let deviceLanguage else {
                throw FlowTaleServicesError.failedToGetDeviceLanguage
            }
            
            let baseChapter = Chapter(
                storyId: UUID(),
                title: "",
                sentences: [],
                audioVoice: voice,
                audio: ChapterAudio(data: Data()),
                passage: "",
                difficulty: difficulty,
                language: language,
                storyPrompt: storyPrompt
            )
            
            let jsonString = try await generateFirstChapterRequest(baseChapter: baseChapter, deviceLanguage: deviceLanguage)
            guard let jsonData = jsonString.data(using: .utf8) else {
                throw FlowTaleServicesError.failedToGetResponseData
            }
            
            let decoder = JSONDecoder.createChapterResponseDecoder(deviceLanguage: deviceLanguage, targetLanguage: language)
            let chapterResponse = try decoder.decode(ChapterResponse.self, from: jsonData)
            let passage = chapterResponse.sentences.reduce("") { $0 + $1.original }
            
            var newChapter = baseChapter
            newChapter.id = UUID()
            newChapter.title = chapterResponse.chapterNumberAndTitle ?? ""
            newChapter.sentences = chapterResponse.sentences
            newChapter.passage = passage
            newChapter.storyTitle = chapterResponse.titleOfNovel ?? ""
            newChapter.chapterSummary = chapterResponse.briefLatestStorySummary
            newChapter.lastUpdated = .now
            return newChapter
        } catch {
            throw FlowTaleServicesError.failedToDecodeSentences
        }
    }

    func generateChapter(previousChapters: [Chapter], deviceLanguage: Language?) async throws -> Chapter {
        do {
            guard let deviceLanguage else {
                throw FlowTaleServicesError.failedToGetDeviceLanguage
            }
            
            let jsonString = try await generateChapterRequest(previousChapters: previousChapters,
                                                              deviceLanguage: deviceLanguage)
            guard let jsonData = jsonString.data(using: .utf8) else {
                throw FlowTaleServicesError.failedToGetResponseData
            }
            
            let baseChapter = previousChapters.last ?? Chapter(storyId: UUID(), title: "", sentences: [], audioVoice: .xiaoxiao, audio: ChapterAudio(data: Data()), passage: "", language: .mandarinChinese)
            let decoder = JSONDecoder.createChapterResponseDecoder(deviceLanguage: deviceLanguage, targetLanguage: baseChapter.language)
            let chapterResponse = try decoder.decode(ChapterResponse.self, from: jsonData)
            let passage = chapterResponse.sentences.reduce("") { $0 + $1.original }
            
            var newChapter = baseChapter
            newChapter.id = UUID()
            newChapter.title = chapterResponse.chapterNumberAndTitle ?? ""
            newChapter.sentences = chapterResponse.sentences
            newChapter.passage = passage

            if let title = chapterResponse.titleOfNovel {
                newChapter.storyTitle = title
            }
            newChapter.chapterSummary = chapterResponse.briefLatestStorySummary
            newChapter.lastUpdated = .now
            return newChapter
        } catch {
            throw FlowTaleServicesError.failedToDecodeSentences
        }
    }

    private func generateFirstChapterRequest(baseChapter: Chapter, deviceLanguage: Language) async throws -> String {
        var messages: [[String: String]] = []
        
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
        
        """
        initialPrompt.append(promptDetails)
        
        messages.append(["role": "user", "content": initialPrompt])
        
        var requestBody: [String: Any] = ["messages": messages]
        requestBody["response_format"] = sentenceSchema(originalLanguage: deviceLanguage,
                                                        translationLanguage: baseChapter.language,
                                                        shouldCreateTitle: true)

        return try await RequestFactory.makeRequest(type: APIRequestType.openRouter(.geminiFlash),
                                                    requestBody: requestBody)
    }

    private func generateChapterRequest(previousChapters: [Chapter],
                                        deviceLanguage: Language?) async throws -> String {
        guard let deviceLanguage else {
            throw FlowTaleServicesError.failedToGetDeviceLanguage
        }
        
        guard let baseChapter = previousChapters.last else {
            throw FlowTaleServicesError.failedToGetResponseData
        }
        
        var messages: [[String: String]] = []
        
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
        
        """
        nextChapterPrompt.append(promptDetails)
        
        messages.append(["role": "user", "content": nextChapterPrompt])
        
        var requestBody: [String: Any] = ["messages": messages]
        requestBody["response_format"] = sentenceSchema(originalLanguage: deviceLanguage,
                                                        translationLanguage: baseChapter.language,
                                                        shouldCreateTitle: false)

        return try await RequestFactory.makeRequest(type: APIRequestType.openRouter(.geminiFlash),
                                                    requestBody: requestBody)
    }
}
