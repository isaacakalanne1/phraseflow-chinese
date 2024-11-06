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
    func generateStory(genres: [Genre], voice: Voice) async throws -> Story
    func generateChapter(previousChapter: Chapter, voice: Voice) async throws -> ChapterResponse
    func fetchDefinition(of character: String, withinContextOf sentence: Sentence) async throws -> String
}

final class FastChineseServices: FastChineseServicesProtocol {

    let generativeModel =
      GenerativeModel(
        name: "gemini-1.5-flash-8b-latest",
        apiKey: "AIzaSyBJz8qmCuAK5EO9AzQLl99ed6TlvHKRjCI"
      )

    func generateStory(genres: [Genre], voice: Voice) async throws -> Story {
        let chapterResponse = try await generateChapter(type: .first(setting: StorySetting.allCases.randomElement() ?? .ancientChina),
                                                        voice: voice)
        let chapter = Chapter(storyTitle: chapterResponse.storyTitle, sentences: chapterResponse.sentences)
        return Story(storyOverview: "Story overview here",
                     latestStorySummary: chapterResponse.latestStorySummary,
                     difficulty: .HSK1,
                     title: chapterResponse.storyTitle,
                     description: "Description here",
                     chapters: [chapter])
    }

    func generateChapter(previousChapter: Chapter, voice: Voice) async throws -> ChapterResponse {
        try await generateChapter(type: .next(previousChapter: previousChapter), voice: voice)
    }

    private func generateChapter(type: ChapterType, voice: Voice) async throws -> ChapterResponse {
        let initialPrompt = """
        You are the an award-winning Mandarin Chinese novelist. Write a chapter from an engaging Mandarin novel.
        Do not include any explaining statements before or after the story. Simply write the most amazing, engaging, suspenseful story possible.
        You output only the expected story in JSON format, with each sentence split into entries in the list.
        You output no explaining text before or after the JSON, only the JSON.
        You output data in the following format:
        {
            "sentences": [
                {
                    "sentenceIndex": 0,
                    "mandarin": "你好",
                    "pinyin": ["nǐ", "hǎo"],
                    "english": "Hello",
                    "speechStyle": "Speech style based on Mandarin sentence"
                },
                {
                    "sentenceIndex": 1,
                    "mandarin": "谢谢",
                    "pinyin": ["xiè", "xie"],
                    "english": "Thank you",
                    "speechStyle": "speech style based on Mandarin sentence"
                },
                {
                    "sentenceIndex": 2,
                    "mandarin": "再见",
                    "pinyin": ["zài", "jiàn"],
                    "english": "Goodbye",
                    "speechStyle": "speech style based on Mandarin sentence"
                }
            ],
            "storyTitle": "Short story title in English. Create a short title if no title is provided below",
            "latestStorySummary": "Suspenseful short teaser description of the story so far, which makes the reader want to read the above chapter."
        }
        Always use "lyrical" for third-person text. Only use other speech styles when a character is speaking, not for describing a character's feeling or such.
        For describing a character's feelings, still use "lyrical".
        Do not nest JSON statements within each other. Ensure the list only has a depth of 1 JSON object.
        Separate each pinyin in the list into their individual sounds. For example, "níanqīng" would be separated into ["nían", "qīng"]
        Include punctuation in the pinyin, to match the Mandarin, such as commas, and full stops. The punctuation should be its own item in the pinyin list, such as ["nǐ", "，"]. Use Mandarin punctuation.
        Do not include the ```json prefix tag or or ``` suffix tag in your response.
        """

        let mainPrompt: String
        switch type {
        case .first(let setting):
            mainPrompt = """
        Write the first chapter of an engaging Mandarin novel.
        The reader should be amazed an AI came up with it.
        Use vocabulary a 5 year old child could understand.
        The chapter should be 20 sentences long.

        This is the setting of the story:
        \(setting.title)

        These are the available speech styles:
        \(String(describing: voice.availableSpeechStyles.map({ $0.ssmlName })))
        """
        case .next(let previousChapter):
            mainPrompt = """
        Write the next chapter of an engagin Mandarin novel.
        The reader should be amazed an AI came up with it.
        Use vocabulary a 5 year old child could understand.
        The chapter should be 20 sentences long.

        "This is the previous chapter:
        \(previousChapter.passage)

        These are the available speech styles:
        \(String(describing: voice.availableSpeechStyles.map({ $0.ssmlName })))
        """
        }

        let response = try await makeGeminiRequest(initialPrompt: initialPrompt, mainPrompt: mainPrompt).data(using: .utf8)
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
        let mainPrompt = "Provide a definition for \(character) in \(sentence.mandarin)"
        let response = try await makeOpenAIRequest(initialPrompt: initialPrompt, mainPrompt: mainPrompt)
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

    private func makeOpenAIRequest(initialPrompt: String, mainPrompt: String) async throws -> String {

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestData = DefineCharacterRequest(messages: [
            .init(role: "system",
                  content: initialPrompt),
            .init(role: "user",
                  content: mainPrompt)
        ])

        guard let jsonData = try? JSONEncoder().encode(requestData) else {
            throw FastChineseServicesError.failedToEncodeJson
        }

        let (data, _) = try await URLSession.shared.upload(for: request, from: jsonData)
        guard let response = try? JSONDecoder().decode(GPTResponse.self, from: data),
              let responseString = response.choices.first?.message.content else {
            throw FastChineseServicesError.failedToDecodeJson
        }
        return responseString

    }

}
