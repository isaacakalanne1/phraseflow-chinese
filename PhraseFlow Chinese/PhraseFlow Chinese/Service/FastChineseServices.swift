//
//  FastChineseService.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation

enum FastChineseServicesError: Error {
    case failedToCreateSsmlData
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
}
