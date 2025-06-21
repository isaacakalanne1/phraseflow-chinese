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
            let jsonString = try await generateChapterRequest(chapter: chapter,
                                                              deviceLanguage: deviceLanguage)
            guard let jsonData = jsonString.data(using: .utf8) else {
                throw FlowTaleServicesError.failedToGetResponseData
            }
            let decoder = JSONDecoder.createChapterResponseDecoder(deviceLanguage: deviceLanguage, targetLanguage: chapter.language)
            let chapterResponse = try decoder.decode(ChapterResponse.self, from: jsonData)
            let passage = chapterResponse.sentences.reduce("") { $0 + $1.original }
            var newChapter = chapter
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

    private func generateChapterRequest(chapter: Chapter,
                                        deviceLanguage: Language?) async throws -> String {
        guard let deviceLanguage else {
            throw FlowTaleServicesError.failedToGetDeviceLanguage
        }
        var messages: [[String: String]] = []
        var initialPrompt = """
        Write an incredible first chapter of a story written in \(chapter.language.descriptiveEnglishName).
        
        """
        var furtherPrompt = """
        Write an incredible next chapter of a story written in \(chapter.language.descriptiveEnglishName).
        
        """
        if let storyPrompt = chapter.storyPrompt {
            let settingPrompt = "The story is in the following setting: \(storyPrompt)"
            initialPrompt.append(settingPrompt)
            furtherPrompt.append(settingPrompt)
        }

        let promptDetails = """
        
        \(chapter.difficulty.vocabularyPrompt).
        Use a vocabulary of around 150 \(chapter.language.descriptiveEnglishName) words.
        The chapter should be around 400 \(chapter.language.descriptiveEnglishName) words long.
        
        """
        initialPrompt.append(promptDetails)
        furtherPrompt.append(promptDetails)

        // For new stories, use initial prompt; for existing chapters, use further prompt  
        if chapter.storyTitle.isEmpty {
            messages.append(["role": "user", "content": initialPrompt])
        } else {
            // If this is a continuation, add previous chapter context
            if !chapter.passage.isEmpty {
                messages.append(["role": "system", "content": chapter.title + "\n" + chapter.passage])
            }
            messages.append(["role": "user", "content": furtherPrompt])
        }
        
        var requestBody: [String: Any] = ["messages": messages]
        requestBody["response_format"] = sentenceSchema(originalLanguage: deviceLanguage,
                                                        translationLanguage: chapter.language,
                                                        shouldCreateTitle: chapter.storyTitle.isEmpty)

        return try await RequestFactory.makeRequest(type: APIRequestType.openRouter(.geminiFlash),
                                                    requestBody: requestBody)
    }
}
