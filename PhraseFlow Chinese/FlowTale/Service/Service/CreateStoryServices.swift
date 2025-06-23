//
//  CreateStoryServices.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation

class CreateStoryServices: CreateStoryServicesProtocol {

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

    private func generateChapterRequest(previousChapters: [Chapter],
                                        deviceLanguage: Language?) async throws -> String {
        guard let deviceLanguage else {
            throw FlowTaleServicesError.failedToGetDeviceLanguage
        }
        
        let baseChapter = previousChapters.last ?? Chapter(storyId: UUID(), title: "", sentences: [], audioVoice: .xiaoxiao, audio: ChapterAudio(data: Data()), passage: "", language: .mandarinChinese)
        let isFirstChapter = previousChapters.count <= 1 || previousChapters.first?.storyTitle.isEmpty == true
        
        var messages: [[String: String]] = []
        var initialPrompt = """
        Write an incredible first chapter of a story written in \(baseChapter.language.descriptiveEnglishName).
        
        """
        var furtherPrompt = """
        Write an incredible next chapter of a story written in \(baseChapter.language.descriptiveEnglishName).
        
        """
        if let storyPrompt = baseChapter.storyPrompt {
            let settingPrompt = "The story is in the following setting: \(storyPrompt)"
            initialPrompt.append(settingPrompt)
            furtherPrompt.append(settingPrompt)
        }

        let promptDetails = """
        
        \(baseChapter.difficulty.vocabularyPrompt).
        Use a vocabulary of around 150 \(baseChapter.language.descriptiveEnglishName) words.
        The chapter should be around 400 \(baseChapter.language.descriptiveEnglishName) words long.
        
        """
        initialPrompt.append(promptDetails)
        furtherPrompt.append(promptDetails)

        // For new stories, use initial prompt; for existing chapters, use further prompt  
        if isFirstChapter {
            messages.append(["role": "user", "content": initialPrompt])
        } else {
            // If this is a continuation, add previous chapter context
            if let lastChapter = previousChapters.last, !lastChapter.passage.isEmpty {
                messages.append(["role": "system", "content": lastChapter.title + "\n" + lastChapter.passage])
            }
            messages.append(["role": "user", "content": furtherPrompt])
        }
        
        var requestBody: [String: Any] = ["messages": messages]
        requestBody["response_format"] = sentenceSchema(originalLanguage: deviceLanguage,
                                                        translationLanguage: baseChapter.language,
                                                        shouldCreateTitle: isFirstChapter)

        return try await RequestFactory.makeRequest(type: APIRequestType.openRouter(.geminiFlash),
                                                    requestBody: requestBody)
    }
}
