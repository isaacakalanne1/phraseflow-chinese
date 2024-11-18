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
    func generateStory(voice: Voice, difficulty: Difficulty) async throws -> Story
    func generateChapter(story: Story, voice: Voice, difficulty: Difficulty) async throws -> ChapterResponse
    func fetchDefinition(of character: String, withinContextOf sentence: Sentence) async throws -> String
}

final class FastChineseServices: FastChineseServicesProtocol {

    let generativeModel =
      GenerativeModel(
        name: "gemini-1.5-flash-8b-latest",
        apiKey: "AIzaSyBJz8qmCuAK5EO9AzQLl99ed6TlvHKRjCI"
      )

    func generateStory(voice: Voice, difficulty: Difficulty) async throws -> Story {
        let storySetting: StorySetting = .allCases.randomElement() ?? .ancientChina
        let chapterResponse = try await generateChapter(type: .first(setting: storySetting), voice: voice, difficulty: difficulty)

        let sentences = chapterResponse.sentences.map({ Sentence(mandarin: $0.mandarin.replacingOccurrences(of: " ", with: ""),
                                                                 englishTranslation: $0.englishTranslation,
                                                                 speechRole: $0.speechRole) })
        let chapter = Chapter(storyTitle: "Story title here", sentences: sentences)

        return Story(latestStorySummary: chapterResponse.latestStorySummary,
                     difficulty: .beginner,
                     title: "Story title here",
                     chapters: [chapter])
    }

    func generateChapter(story: Story, voice: Voice, difficulty: Difficulty) async throws -> ChapterResponse {
        try await generateChapter(type: .next(story: story), voice: voice, difficulty: difficulty)
    }

    private func generateChapter(type: ChapterType, voice: Voice, difficulty: Difficulty) async throws -> ChapterResponse {
        let mainPrompt: String
        switch type {
        case .first(let setting):
            mainPrompt = """
        Write a story in this setting:
        \(setting.title)

        Make sure to provide both the Mandarin and translated English in the JSON. The English is needed to allow the reader learning Chinese to understand the Mandarin sentence.
        """

        case .next(let story):
            mainPrompt = """
        This is the story so far:
        \(story.chapters.reduce("") { $0 + "\n\n" + $1.passage })

        Continue the story.

        Make sure to provide both the Mandarin and translated English in the JSON.
        """
        }
//        Use very very short sentences, and very very extremely simple language.
        let response = try await makeOpenAIRequest(initialPrompt: getStoryGenerationGuide(voice: voice, difficulty: difficulty), mainPrompt: mainPrompt)
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
        let response = try await makeOpenAIRequest(initialPrompt: initialPrompt, mainPrompt: mainPrompt, shouldUseSchema: false)
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

    private func makeOpenAIRequest(initialPrompt: String, mainPrompt: String, shouldUseSchema: Bool = true) async throws -> String {

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        var requestBody: [String: Any] = [
            "model": "gpt-4o-mini-2024-07-18",
            "messages": [
                ["role": "system", "content": initialPrompt],
                ["role": "user", "content": mainPrompt]
            ],
        ]
        if shouldUseSchema {
            requestBody["response_format"] = sentenceSchema
        }
        let requestData = DefineCharacterRequest(messages: [
            .init(role: "system",
                  content: initialPrompt),
            .init(role: "user",
                  content: mainPrompt)
        ])

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

    private func getStoryGenerationGuide(voice: Voice, difficulty: Difficulty) -> String {
        """
        You are the an award-winning Mandarin Chinese novelist. Write a chapter from an engaging Mandarin novel. Use Mandarin Chinese names in the story.

        Start each chapter with "Chapter 1", "Chapter 2", etc, in Mandarin Chinese.

        Use the " character for speech marks.

        In the JSON, provide both the Mandarin sentence and the translated English sentence.

        In the JSON:
        - latestStorySummary: This is a brief summary of the story so far in English. This summary is of the story which happens before the new part of the story you write.
        - mandarin: The story sentence written in Mandarin Chinese.
        - englishTranslation: The story sentence written in English.

        - speechRole: This matches the speaker of the speaker of the sentence.
        The speechRole should be either "male", "female", or "narrator".
        Only use the above speechRoles, never create your own.

        Write a Mandarin chinese story with controversial characters. That is, each character in the story will have some positive aspects, and some aspects which the reader is unsure whether they should side or not. Do not explicitly mention "ah, is this right? la di dah", simply have this be a core element of the story.
        Everything emotional in the story should be insinuated. Lean heavily on "show, not tell" for how characters are feeling, and how events are unfolding.
        Don't have the story be overly positive, and don't have characters randomly, tritely affirm "with x's help, they knew they could succeed!", "with x, they felt stronger from their support" etc, please stop doing this. You are an author, not a moralist lecturer. Write a compelling, engaging, turbulent story.
        Only use Mandarin Chinese characters in the Mandarin section of the JSON. Never include English characters or words in the Mandarin section of the JSON.

        Below are some extra details:

        The story should be written at a specific difficulty level, from a scale of 1 to 10, which will be specified below.
        1 is absolute beginner Mandarin Chinese, the most absolute basic words and vocabulary, very short sentences, very simple grammar and sentence structure.
        10 is absolute professional Mandarin Chinese, with highly advanced grammar, vocabulary, and sentence structures.
        Any numbers between are a linear transition between the above specified minimum and maximum.

        Based on the above scale of 1 to \(difficulty.maxIntValue), write a story with the below difficulty level.
        DIFFICULTY LEVEL: \(difficulty.intValue)

        The Chapter length itself should still always be long, for all difficulty levels.

        Make sure the English section of the JSON writes the English translation of the mandarin sentence. It must do this to allow the reader to learn Mandarin Chinese.
        """
        // Using the above guidelines, write a story in the style of George R R Martin.
    }
}
