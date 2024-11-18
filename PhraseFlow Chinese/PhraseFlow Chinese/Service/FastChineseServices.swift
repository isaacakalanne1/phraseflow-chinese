//
//  FastChineseService.swift
//  FastChinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import GoogleGenerativeAI

enum FastChineseServicesError: Error {
    case failedToGetResponseData
    case failedToEncodeJson
    case failedToDecodeJson
    case failedToDecodeSentences
}

protocol FastChineseServicesProtocol {
    func generateStory() async throws -> Story
    func generateChapter(story: Story?) async throws -> ChapterResponse
    func fetchDefinition(of character: String, withinContextOf sentence: Sentence) async throws -> String
}

final class FastChineseServices: FastChineseServicesProtocol {

    let generativeModel =
      GenerativeModel(
        name: "gemini-1.5-flash-8b-latest",
        apiKey: "AIzaSyBJz8qmCuAK5EO9AzQLl99ed6TlvHKRjCI"
      )

    func generateStory() async throws -> Story {
        let storySetting: StorySetting = .allCases.randomElement() ?? .ancientChina
        let chapterResponse = try await generateChapter(story: nil)

        let sentences = chapterResponse.sentences.map({ Sentence(mandarin: $0.mandarin.replacingOccurrences(of: " ", with: ""),
                                                                 englishTranslation: $0.englishTranslation,
                                                                 speechRole: $0.speechRole) })
        let chapter = Chapter(storyTitle: "Story title here", sentences: sentences)

        return Story(latestStorySummary: chapterResponse.latestStorySummary,
                     difficulty: .beginner,
                     title: "Story title here",
                     chapters: [chapter])
    }

    func generateChapter(story: Story?) async throws -> ChapterResponse {
//        Use very very short sentences, and very very extremely simple language.
        let response = try await generateStory(story: story)
            .data(using: .utf8)
        guard let response else {
            throw FastChineseServicesError.failedToGetResponseData
        }

        do {
            return try JSONDecoder().decode(ChapterResponse.self, from: response)
        } catch {
            throw FastChineseServicesError.failedToDecodeSentences
        }
    }

    func fetchDefinition(of character: String, withinContextOf sentence: Sentence) async throws -> String {
        let initialPrompt =
"""
        You are an AI assistant that provides English definitions for characters in Chinese sentences. Your explanations are brief, and simple to understand.
        You provide the pinyin for the Chinese character in brackets after the Chinese character.
        If the character is used as part of a larger word, you also provide the pinyin and definition for each character in this overall word.
        You also provide the definition of the word in the context of the overall sentence.
        You never repeat the Chinese sentence, and never translate the whole of the Chinese sentence into English.
"""
        let mainPrompt =
"""
        Provide a definition for this word: "\(character)"
        If the word is made of different characters, also provide brief definitions for each of the characters in the word.
        Also explain the word in the context of the sentence: "\(sentence.mandarin)".
        Don't define other words in the sentence.
"""
        var messages: [[String: String]] = [
            ["role": "user", "content": initialPrompt],
            ["role": "user", "content": mainPrompt]
        ]

        var requestBody: [String: Any] = [
            "model": "gpt-4o-mini-2024-07-18",
            "messages": messages
        ]

        let response = try await makeOpenAIRequest(requestBody: requestBody)
        return response
    }

    private func makeGeminiRequest(initialPrompt: String, mainPrompt: String) async throws -> String {

        let prompt = initialPrompt + "\n\n" + mainPrompt
        let response = try await generativeModel.generateContent(prompt)
        guard let responseString = response.text else {
            throw FastChineseServicesError.failedToGetResponseData
        }
        return responseString
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
    }

    private func generateStory(story: Story?) async throws -> String {

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let initialPrompt = "Write an incredible first chapter of a story set in a forest."
        var requestBody: [String: Any] = [
            "model": "gpt-4o-mini-2024-07-18",
        ]

        var messages: [[String: String]] = [["role": "user", "content": initialPrompt]]
        if let chapters = story?.chapters {
            for chapter in chapters {
                messages.append(["role": "system", "content": chapter.passage])
                messages.append(["role": "user", "content": "Continue the story"])
            }
        }
        requestBody["messages"] = messages
        requestBody["response_format"] = sentenceSchema

        return try await makeOpenAIRequest(requestBody: requestBody)
    }

    private func makeOpenAIRequest(requestBody: [String: Any]) async throws -> String {

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            throw FastChineseServicesError.failedToEncodeJson
        }

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 1200
        sessionConfig.timeoutIntervalForResource = 1200
        let session = URLSession(configuration: sessionConfig)

        let (data, _) = try await session.upload(for: request, from: jsonData)
        guard let response = try? JSONDecoder().decode(GPTResponse.self, from: data),
              let responseString = response.choices.first?.message.content else {
            throw FastChineseServicesError.failedToDecodeJson
        }
        return responseString

    }
}
