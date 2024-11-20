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
    func generateStory(story: Story?, settings: SettingsState) async throws -> Story
    func fetchDefinition(of character: String, withinContextOf sentence: Sentence) async throws -> String
}

final class FastChineseServices: FastChineseServicesProtocol {

    let generativeModel =
      GenerativeModel(
        name: "gemini-1.5-flash-8b-latest",
        apiKey: "AIzaSyBJz8qmCuAK5EO9AzQLl99ed6TlvHKRjCI"
      )

    func generateStory(story: Story?, settings: SettingsState) async throws -> Story {
//        Use very very short sentences, and very very extremely simple language.
        let (response, setting) = try await continueStory(story: story, settings: settings)
        let responseString = response.data(using: .utf8)
        guard let responseString else {
            throw FastChineseServicesError.failedToGetResponseData
        }

        do {
            let (chapterResponse, storySetting) = (try JSONDecoder().decode(ChapterResponse.self, from: responseString), setting)
            let sentences = chapterResponse.sentences.map({ Sentence(mandarin: $0.mandarin.replacingOccurrences(of: " ", with: ""),
                                                                     englishTranslation: $0.englishTranslation,
                                                                     speechRole: $0.speechRole) })
            let chapter = Chapter(storyTitle: "Story title here", sentences: sentences)

            if var story {
                if story.chapters.isEmpty {
                    story.chapters = [chapter]
                } else {
                    story.chapters.append(chapter)
                }
                story.latestStorySummary = chapterResponse.latestStorySummary
                story.currentChapterIndex = story.chapters.count - 1
                story.lastUpdated = .now
                return story
            } else {
                return Story(latestStorySummary: chapterResponse.latestStorySummary,
                             difficulty: .beginner,
                             title: "Story title here",
                             chapters: [chapter],
                             setting: storySetting)
            }
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

    private func continueStory(story: Story?, settings: SettingsState) async throws -> (String, StorySetting) {

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let setting = (story?.setting ?? StorySetting.allCases.randomElement()) ?? StorySetting.medieval
        var initialPrompt = "Write an incredible first chapter of a story set in \(setting.settingName). "
        switch settings.difficulty {
        case .beginner:
            initialPrompt.append("Use very simple, elementary-level vocabulary.")
        case .intermediate:
            initialPrompt.append("Use simple vocabulary.")
        case .advanced:
            break
        case .expert:
            break
        }

        let qualityPrompt = """

The chapter should be incredible, and make the reader absolutely curious to read what happens in the next chapter.
The chapter should have a really engaging plot with complex, three-dimensional characters.
The chapter should also be long, around 20 sentences, to really allow plot to happen in each chapter.
"""
        initialPrompt.append(qualityPrompt)
        var requestBody: [String: Any] = [
            "model": "gpt-4o-mini-2024-07-18",
        ]

        var messages: [[String: String]] = [["role": "user", "content": initialPrompt]]
        if let chapters = story?.chapters {
            for chapter in chapters {
                var continueStoryPrompt = "Continue the story."
                continueStoryPrompt.append(qualityPrompt)
                messages.append(["role": "system", "content": chapter.passage])
                messages.append(["role": "user", "content": continueStoryPrompt])
            }
        }
        requestBody["messages"] = messages
        requestBody["response_format"] = sentenceSchema

        return (try await makeOpenAIRequest(requestBody: requestBody), setting)
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
