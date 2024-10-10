//
//  FastChineseService.swift
//  FastChinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation

enum FastChineseServicesError: Error {
    case failedToCreateSsmlData
    case failedToEncodeJson
    case failedToDecodeJson
    case failedToDecodeSentences
}

protocol FastChineseServicesProtocol {
    func generateChapter(using info: ChapterGenerationInfo) async throws -> [Sentence]
    func fetchDefinition(of character: String, withinContextOf sentence: String) async throws -> GPTResponse
}

final class FastChineseServices: FastChineseServicesProtocol {
    func generateChapter(using info: ChapterGenerationInfo) async throws -> [Sentence] {
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestData = DefineCharacterRequest(messages: [
            .init(role: "system",
                  content: """
                  You are a Mandarin story generator. You output only the expected story in JSON format, with each sentence split into entries in the list.
                  You output no explaining text before or after the JSON, only the JSON.
                  You output data in the following format: [ { "mandarin": "你好", "pinyin": ["nǐ", "hǎo"], "english": "Hello" }, { "mandarin": "谢谢", "pinyin": ["xiè", "xie"], "english": "Thank you" }, { "mandarin": "再见", "pinyin": ["zài", "jiàn"], "english": "Goodbye" } ]
                  You are a master at pinyin and write the absolute best, most accurate tone markings for the pinyin, based on context, and including all relevant neutral tones.
                  Include punctuation in the pinyin, to match the Mandarin, such as commas, and full stops. The punctuation should be its own item in the pinyin list, such as ["nǐ", "，"]. Use Mandarin punctuation.
                  """),
            .init(role: "user",
                  content: """
        Generate a captivating, emotional, and engaging story, with each sentence split in the same structure as the list above.
        The story should be amazing and captivating, and the reader should be amazed an AI came up with it.
        Write the first chapter of this story. The chapter should be 20-30 lines long.
        """)
        ])

        guard let jsonData = try? JSONEncoder().encode(requestData) else {
            throw FastChineseServicesError.failedToEncodeJson
        }

        let (data, _) = try await URLSession.shared.upload(for: request, from: jsonData)
        guard let response = try? JSONDecoder().decode(GPTResponse.self, from: data) else {
            throw FastChineseServicesError.failedToDecodeJson
        }
        guard let sentences = response.decodedSentences() else {
            throw FastChineseServicesError.failedToDecodeSentences
        }
        return sentences
    }

    func fetchDefinition(of character: String, withinContextOf sentence: String) async throws -> GPTResponse {

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestData = DefineCharacterRequest(messages: [
            .init(role: "system",
                  content: "You are an AI assistant that provides English definitions for characters in Chinese sentences. Your explanations are brief, and simple to understand. You provide the pinyin for the Chinese character in brackets after the Chinese character. If the character is used as part of a larger word, you also provide the pinyin and definition for each character in this overall word. You never repeat the Chinese sentence, and never translate the whole of the Chinese sentence into English."),
            .init(role: "user",
                  content: "Provide a definition for \(character) in \(sentence)")
        ])

        guard let jsonData = try? JSONEncoder().encode(requestData) else {
            throw FastChineseServicesError.failedToEncodeJson
        }

        let (data, response) = try await URLSession.shared.upload(for: request, from: jsonData)
        guard let response = try? JSONDecoder().decode(GPTResponse.self, from: data) else { // TODO: May need to update decode type to array, depending on API documentation
            throw FastChineseServicesError.failedToDecodeJson
        }
        return response
    }
}
