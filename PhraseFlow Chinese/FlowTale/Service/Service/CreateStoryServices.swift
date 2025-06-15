//
//  CreateStoryServices.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation

class CreateStoryServices: CreateStoryServicesProtocol {

    func generateStory(story: Story, deviceLanguage: Language?) async throws -> Story {
        do {
            guard let deviceLanguage else {
                throw FlowTaleServicesError.failedToGetDeviceLanguage
            }
            let jsonString = try await generateStoryRequest(story: story,
                                                            deviceLanguage: deviceLanguage)
            guard let jsonData = jsonString.data(using: .utf8) else {
                throw FlowTaleServicesError.failedToGetResponseData
            }
            let decoder = JSONDecoder.createChapterResponseDecoder(deviceLanguage: deviceLanguage, targetLanguage: story.language)
            let chapterResponse = try decoder.decode(ChapterResponse.self, from: jsonData)
            let passage = chapterResponse.sentences.reduce("") { $0 + $1.original }
            let chapter = Chapter(title: chapterResponse.chapterNumberAndTitle ?? "",
                                  sentences: chapterResponse.sentences,
                                  audio: .init(data: Data()),
                                  passage: passage)

            var story = story
            if story.chapters.isEmpty {
                story.chapters = [chapter]
            } else {
                story.chapters.append(chapter)
            }

            if let title = chapterResponse.titleOfNovel {
                story.title = title
            }
            story.briefLatestStorySummary = chapterResponse.briefLatestStorySummary
            story.currentChapterIndex = story.chapters.count - 1
            story.lastUpdated = .now
            return story
        } catch {
            throw FlowTaleServicesError.failedToDecodeSentences
        }
    }

    private func generateStoryRequest(story: Story,
                                      deviceLanguage: Language?) async throws -> String {
        guard let deviceLanguage else {
            throw FlowTaleServicesError.failedToGetDeviceLanguage
        }
        var messages: [[String: String]] = []
        var initialPrompt = """
        Write an incredible first chapter of a story written in \(story.language.descriptiveEnglishName).
        
        """
        var furtherPrompt = """
        Write an incredible next chapter of a story written in \(story.language.descriptiveEnglishName).
        
        """
        if let storyPrompt = story.storyPrompt {
            let settingPrompt = "The story is in the following setting: \(storyPrompt)"
            initialPrompt.append(settingPrompt)
            furtherPrompt.append(settingPrompt)
        }

        let promptDetails = """
        
        \(story.difficulty.vocabularyPrompt).
        Use a vocabulary of around 150 \(story.language.descriptiveEnglishName) words.
        The chapter should be around 400 \(story.language.descriptiveEnglishName) words long.
        
        """
        initialPrompt.append(promptDetails)
        furtherPrompt.append(promptDetails)

        messages.append(["role": "user", "content": initialPrompt])
        for chapter in story.chapters.suffix(20) {
            messages.append(["role": "system", "content": chapter.title + "\n" + chapter.passage])
            messages.append(["role": "user", "content": furtherPrompt])
        }
        var requestBody: [String: Any] = ["messages": messages]
        requestBody["response_format"] = sentenceSchema(originalLanguage: deviceLanguage,
                                                        translationLanguage: story.language,
                                                        shouldCreateTitle: story.title.isEmpty)

        return try await RequestFactory.makeRequest(type: APIRequestType.openRouter(.geminiFlash),
                                                    requestBody: requestBody)
    }
}
