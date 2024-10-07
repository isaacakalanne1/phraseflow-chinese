//
//  FastChineseService.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation

enum FastChineseServicesError: Error {
    case failedToCreateSsmlData
    case failedToEncodeJson
    case failedToDecodeJson
    case failedToDecodePhrases
}

protocol FastChineseServicesProtocol {
    func fetchPhrases(category: PhraseCategory) async throws -> [Sentence]
    func fetchAzureTextToSpeech(phrase: Sentence) async throws -> Data
    func fetchDefinition(of character: String, withinContextOf phrase: String) async throws -> GPTResponse
}

final class FastChineseServices: FastChineseServicesProtocol {
    func fetchPhrases(category: PhraseCategory) async throws -> [Sentence] {
        let deploymentId = "gpt-4o-mini"
        let version = "2024-07-18"

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestData = DefineCharacterRequest(messages: [
            .init(role: "system",
                  content: """
                  You are a JSON generator, who takes great pleasure and enjoyment in generating Mandarin phrases. You output only the expected JSON data for the user's input, with no explaining text. You output data in the following format: [ { "mandarin": "你好", "pinyin": "nǐ hǎo", "english": "Hello" }, { "mandarin": "谢谢", "pinyin": "xièxiè", "english": "Thank you" }, { "mandarin": "再见", "pinyin": "zàijiàn", "english": "Goodbye" } ]
                  """),
            .init(role: "user",
                  content: "Write JSON to produce 5 \(category.quantifier) Mandarin phrases. Ensure the correct tones are used, including neutral tones, and changing tones such as those for 不 and 一")
        ])

        guard let jsonData = try? JSONEncoder().encode(requestData) else {
            throw FastChineseServicesError.failedToEncodeJson
        }

        let (data, response) = try await URLSession.shared.upload(for: request, from: jsonData)
        guard let response = try? JSONDecoder().decode(GPTResponse.self, from: data) else {
            throw FastChineseServicesError.failedToDecodeJson
        }
        guard let phrases = response.decodedPhrases(category: category) else {
            throw FastChineseServicesError.failedToDecodePhrases
        }
        return phrases
    }


    func fetchAzureTextToSpeech(phrase: Sentence) async throws -> Data {
        let subscriptionKey = "144bc0cdea4d44e499927e84e795b27a"
        let region = "eastus"

        var request = URLRequest(url: URL(string: "https://\(region).tts.speech.microsoft.com/cognitiveservices/v1")!)
        request.httpMethod = "POST"
        request.addValue("application/ssml+xml", forHTTPHeaderField: "Content-Type")
        request.addValue("riff-24khz-16bit-mono-pcm", forHTTPHeaderField: "X-Microsoft-OutputFormat")
        request.addValue(subscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")

        let ssml = """
        <speak version='1.0' xml:lang='zh-CN'>
            <voice name='zh-CN-XiaoxiaoNeural'>
                \(phrase.mandarin)
            </voice>
        </speak>
        """

        guard let ssmlData = ssml.data(using: .utf8) else {
            throw FastChineseServicesError.failedToCreateSsmlData
        }


        let (data, response) = try await URLSession.shared.upload(for: request, from: ssmlData)
        return data
    }

    func fetchDefinition(of character: String, withinContextOf phrase: String) async throws -> GPTResponse {
        let deploymentId = "gpt-4o-mini"
        let version = "2024-07-18"

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestData = DefineCharacterRequest(messages: [
            .init(role: "system",
                  content: "You are an AI assistant that provides English definitions for characters in Chinese sentences. Your explanations are brief, and simple to understand. You provide the pinyin for the Chinese character in brackets after the Chinese character. If the character is used as part of a larger word, you also provide the pinyin and definition for each character in this overall word. You never repeat the Chinese sentence, and never translate the whole of the Chinese sentence into English."),
            .init(role: "user",
                  content: "Provide a definition for \(character) in \(phrase)")
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
