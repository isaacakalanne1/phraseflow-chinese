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
}

protocol FastChineseServicesProtocol {
    func fetchAllPhrases(gid: String) async throws -> [Phrase]
    func fetchAzureTextToSpeech(phrase: Phrase) async throws -> Data
}

final class FastChineseServices: FastChineseServicesProtocol {
    func fetchAllPhrases(gid: String) async throws -> [Phrase] {
        let spreadsheetId = "19B3xWuRrTMfpva_IJAyRqGN7Lj3aKlZkZW1N7TwesAE"
        let sheetURL = URL(string: "https://docs.google.com/spreadsheets/d/\(spreadsheetId)/export?format=csv&gid=\(gid)")!

        let (data, response) = try await URLSession.shared.data(from: sheetURL)
        guard let csvString = String(data: data, encoding: .utf8) else {
            return []
        }
        let phrases = csvString.getPhrases()
        return phrases
    }


    func fetchAzureTextToSpeech(phrase: Phrase) async throws -> Data {
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

    func fetchDefinition(of character: String, withinContextOf phrase: String) async throws -> Data {
        let deploymentId = "gpt-4o-mini"
        let version = "2024-07-18"

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestData = DefineCharacterRequest(messages: [
            .init(role: "system",
                  content: "You are an AI assistant that provides English definitions for characters in Chinese sentences. Your explanations are brief, and simple to understand. You provide the pinyin for the Chinese character in brackets after the Chinese character. If the character is used as part of a larger word or context, you also provide the definition for this overall word or context. If the provided word has multiple characters, you also provide pinyin and definitions for each of the characters. You never repeat the Chinese sentence, and never translate the whole of the Chinese sentence into English."),
            .init(role: "user",
                  content: "Provide a definition for \(character) in \(phrase)")
        ])

        guard let jsonData = try? JSONEncoder().encode(requestData) else {
            throw FastChineseServicesError.failedToEncodeJson
        }

        let (data, response) = try await URLSession.shared.upload(for: request, from: jsonData)
        return data
    }
}
