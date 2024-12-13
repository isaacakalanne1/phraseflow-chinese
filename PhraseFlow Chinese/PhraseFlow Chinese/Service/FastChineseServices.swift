//
//  FastChineseService.swift
//  FastChinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation

enum FastChineseServicesError: Error {
    case failedToGetResponseData
    case failedToEncodeJson
    case failedToDecodeJson
    case failedToDecodeSentences
}

protocol FastChineseServicesProtocol {
    func generateStory(story: Story) async throws -> Story
    func fetchDefinition(of character: String, withinContextOf sentence: Sentence, story: Story, settings: SettingsState) async throws -> String
}

final class FastChineseServices: FastChineseServicesProtocol {

    func generateStory(story: Story) async throws -> Story {
        let originalLanguage = Language.allCases.first(where: { $0.identifier == Locale.current.language.languageCode?.identifier })
        do {
            let storyString = try await continueStory(story: story)
            let jsonString = try await convertToJson(story: story,
                                                     storyString: storyString,
                                                     shouldCreateTitle: story.title.isEmpty)
            guard let jsonData = jsonString.data(using: .utf8) else {
                throw FastChineseServicesError.failedToGetResponseData
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .custom({ (keys) -> CodingKey in
                let lastKey = keys.last!
                guard lastKey.intValue == nil else { return lastKey }
                switch lastKey.stringValue {
                case originalLanguage?.schemaKey:
                    return AnyKey(stringValue: "original")!
                case story.language.schemaKey:
                    return AnyKey(stringValue: "translation")!
                case "briefLatestStorySummaryIn\(originalLanguage?.key ?? "English")":
                    return AnyKey(stringValue: "briefLatestStorySummary")!
                case "chapterNumberAndTitleIn\(originalLanguage?.key ?? "English")":
                    return AnyKey(stringValue: "chapterNumberAndTitle")!
                case "titleOfNovelIn\(originalLanguage?.key ?? "English")":
                    return AnyKey(stringValue: "titleOfNovel")!
                default:
                    return AnyKey(stringValue: lastKey.stringValue)!
                }
            })
            let chapterResponse = try decoder.decode(ChapterResponse.self, from: jsonData)
            let sentences = chapterResponse.sentences.map(
                {
                    var translation = $0.translation
                    if story.language == .mandarinChinese {
                        translation = translation.replacingOccurrences(of: " ", with: "")
                    }
                    return Sentence(translation: translation, english: $0.original)
                }
            )
            let chapter = Chapter(title: chapterResponse.chapterNumberAndTitle ?? "", sentences: sentences)

            var story = story
            if story.chapters.isEmpty {
                story.chapters = [chapter]
            } else {
                story.chapters.append(chapter)
            }
            story.briefLatestStorySummary = chapterResponse.briefLatestStorySummary
            story.currentChapterIndex = story.chapters.count - 1
            story.lastUpdated = .now
            return story
        } catch {
            throw FastChineseServicesError.failedToDecodeSentences
        }
    }

    func fetchDefinition(of character: String, withinContextOf sentence: Sentence, story: Story, settings: SettingsState) async throws -> String {
        let languageName = story.language.descriptiveEnglishName
        let initialPrompt =
"""
        You are an AI assistant that provides \(story.deviceLanguage.displayName) definitions for characters in \(languageName) sentences. Your explanations are brief, and simple to understand.
        You provide the pronounciation for the \(languageName) character in brackets after the \(languageName) word.
        If the character is used as part of a larger word, you also provide the pronounciation and definition for each character in this overall word.
        You also provide the definition of the word in the context of the overall sentence.
        You never repeat the \(languageName) sentence, and never translate the whole of the \(languageName) sentence into English.
"""
        let mainPrompt =
"""
Provide a definition for this word: "\(character)"
Also explain the word in the context of the sentence: "\(sentence.translation)".
Don't define other words in the sentence.
Write the definition in \(story.deviceLanguage.displayName).
"""
        let messages: [[String: String]] = [
            ["role": "system", "content": initialPrompt],
            ["role": "user", "content": mainPrompt]
        ]

        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini-2024-07-18",
            "messages": messages
        ]

        return try await makeRequest(type: .openAI, requestBody: requestBody)
    }

    private func continueStory(story: Story) async throws -> String {
        var requestBody: [String: Any] = [
            "model": "meta-llama/llama-3.3-70b-instruct",
        ]

        var messages: [[String: String]] = [
            ["role": "user", "content": "Write an incredible first chapter of a novel in English with complex, three-dimensional characters set in \(story.storyPrompt). \(story.difficulty.vocabularyPrompt)"]
        ]

        for chapter in story.chapters {
            messages.append(["role": "system", "content": chapter.title + "\n" + chapter.passage])
            messages.append(["role": "user", "content": "Write an incredible next chapter of the novel in English with complex, three-dimensional characters. \(story.difficulty.vocabularyPrompt)"])
        }
        requestBody["messages"] = messages

        return try await makeRequest(type: .openRouter, requestBody: requestBody)
    }

    private func convertToJson(story: Story, storyString: String, shouldCreateTitle: Bool) async throws -> String {
        let jsonPrompt = """
Format the following story into JSON. Translate each English sentence into \(story.deviceLanguage == .english ? "" : "\(story.deviceLanguage.descriptiveEnglishName) and ") \(story.language.descriptiveEnglishName).
Ensure each sentence entry is for an individual sentence.
Translate the whole sentence, including names and places.
"""
        var requestBody: [String: Any] = [
            "model": "gpt-4o-mini-2024-07-18",
        ]

        let messages: [[String: String]] = [
            ["role": "system", "content": jsonPrompt],
            ["role": "user", "content": storyString]
        ]
        requestBody["messages"] = messages
        requestBody["response_format"] = sentenceSchema(originalLanguage: story.deviceLanguage,
                                                        translationLanguage: story.language,
                                                        shouldCreateTitle: shouldCreateTitle)

        return try await makeRequest(type: .openAI, requestBody: requestBody)
    }

    private func makeRequest(type: APIRequestType, requestBody: [String: Any]) async throws -> String {
        let request = createURLRequest(baseUrl: type.baseUrl, authKey: type.authKey)

        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            throw FastChineseServicesError.failedToEncodeJson
        }

        let session = createURLSession()

        let (data, _) = try await session.upload(for: request, from: jsonData)
        guard let response = try? JSONDecoder().decode(GPTResponse.self, from: data),
              let responseString = response.choices.first?.message.content else {
            throw FastChineseServicesError.failedToDecodeJson
        }
        return responseString
    }

    private func createURLRequest(baseUrl: String, authKey: String) -> URLRequest {
        var request = URLRequest(url: URL(string: baseUrl)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    private func createURLSession() -> URLSession {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 1200
        sessionConfig.timeoutIntervalForResource = 1200
        return URLSession(configuration: sessionConfig)
    }
}
