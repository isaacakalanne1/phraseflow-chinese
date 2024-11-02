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
    func generateStory(genres: [Genre]) async throws -> Story
    func generateChapter(previousChapter: Chapter) async throws -> ChapterResponse
    func fetchDefinition(of character: String, withinContextOf sentence: Sentence) async throws -> String
}

final class FastChineseServices: FastChineseServicesProtocol {

    let generativeModel =
      GenerativeModel(
        name: "gemini-1.5-flash-8b-latest",
        apiKey: "AIzaSyBJz8qmCuAK5EO9AzQLl99ed6TlvHKRjCI"
      )

    func generateStory(genres: [Genre]) async throws -> Story {
        let chapterResponse = try await generateChapter(type: .first(genres: genres))
        let chapter = Chapter(storyTitle: chapterResponse.storyTitle, sentences: chapterResponse.sentences)
        return Story(storyOverview: "Story overview here",
                     latestStorySummary: chapterResponse.latestStorySummary,
                     difficulty: .HSK1,
                     title: chapterResponse.storyTitle,
                     description: "Description here",
                     chapters: [chapter])
    }

    func generateChapter(previousChapter: Chapter) async throws -> ChapterResponse {
        try await generateChapter(type: .next(previousChapter: previousChapter))
    }

    private func generateChapter(type: ChapterType) async throws -> ChapterResponse {
        let initialPrompt = """
        You are the greatest Mandarin Chinese storywriter alive, who takes great pleasure in creating Mandarin stories. You write stories to help people learn Mandarin Chinese.
        Do not include any explaining statements before or after the story. Simply write the most amazing, engaging, suspenseful story possible.
        You output only the expected story in JSON format, with each sentence split into entries in the list.
        You output no explaining text before or after the JSON, only the JSON.
        You output data in the following format: { "sentences": [ { "mandarin": "你好", "pinyin": ["nǐ", "hǎo"], "english": "Hello" }, { "mandarin": "谢谢", "pinyin": ["xiè", "xie"], "english": "Thank you" }, { "mandarin": "再见", "pinyin": ["zài", "jiàn"], "english": "Goodbye" } ], "storyTitle": "Short story title in English. Create a short title if no title is provided below", "latestStorySummary": "Suspenseful short teaser description of the story so far, which makes the reader want to read the above chapter." }
        Do not nest JSON statements within each other. Ensure the list only has a depth of 1 JSON object.
        You are a master at pinyin and write the absolute best, most accurate tone markings for the pinyin, based on context, and including all relevant neutral tones.
        Separate each pinyin in the list into their individual sounds. For example, "níanqīng" would be separated into ["nían", "qīng"]
        Include punctuation in the pinyin, to match the Mandarin, such as commas, and full stops. The punctuation should be its own item in the pinyin list, such as ["nǐ", "，"]. Use Mandarin punctuation.
        Do not include the ```json prefix tag or or ``` suffix tag in your response.
        """

        let mainPrompt: String
        switch type {
        case .first(let genres):
            mainPrompt = """
        Write the first chapter of a Mandarin story.
        It should be emotional and dramatic.
        The reader should be amazed an AI came up with it.
        Use vocabulary a child could understand.
        The chapter should be 20-30 sentences long.
        The chapter should end in a way that makes the reader curious what happens in the next chapter.

        "These are the genres the story should be in:
        \(genres.map({ $0.rawValue }))
        """
        case .next(let previousChapter):
            mainPrompt = """
        Write the next chapter of this Mandarin story.
        It should be emotional and dramatic.
        The reader should be amazed an AI came up with it.
        Use vocabulary a child could understand.
        The chapter should be 20-30 sentences long.
        The chapter should end in a way that makes the reader curious what happens in the next chapter.

        This is the story title:
        \(previousChapter.storyTitle)

        "This is the previous chapter:
        \(previousChapter.passage)
        """
        }

        let response = try await makeRequest(initialPrompt: initialPrompt, mainPrompt: mainPrompt).data(using: .utf8)
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
        You are an AI assistant that provides English definitions for characters in Chinese sentences.
        You provide the pinyin for the Chinese character in brackets after the Chinese character.
        You also provide the definition of the word in the context of the overall sentence.
        You never repeat the Chinese sentence, and never translate the whole of the Chinese sentence into English.
        Your tranlations and explanations are useful for people learning Mandarin Chinese.
"""
        let mainPrompt = "Provide a definition for \(character) in \(sentence.mandarin)."
        return try await makeRequest(initialPrompt: initialPrompt, mainPrompt: mainPrompt)
    }

    private func makeRequest(initialPrompt: String, mainPrompt: String) async throws -> String {

        let prompt = initialPrompt + "\n\n" + mainPrompt
        let response = try await generativeModel.generateContent(prompt)
        guard let responseString = response.text else {
            throw FastChineseServicesError.failedToGetResponseData
        }
        return responseString
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
    }

}
