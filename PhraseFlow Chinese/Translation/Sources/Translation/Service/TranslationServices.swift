//
//  TranslationServices.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import APIRequest
import Foundation
import Settings
import TextGeneration

enum TranslationServicesError: Error {
    case failedToGetDeviceLanguage
    case failedToGetResponseData
}

class TranslationServices: TranslationServicesProtocol {
    func translateText(
        _ text: String,
        from deviceLanguage: Language?,
        to targetLanguage: Language
    ) async throws -> Chapter {
        let model = APIRequestType.openRouter(.geminiFlash)
        guard let deviceLanguage else {
            throw TranslationServicesError.failedToGetDeviceLanguage
        }

        let prompt = """
        Translate the following text to \(targetLanguage.descriptiveEnglishName).
        Maintain the tone, meaning, and cultural context as accurately as possible.
        
        Text to translate:
        \(text)
        """
        let messages: [[String: String]] = [["role": "system", "content": prompt]]
        var requestBody: [String: Any] = ["messages" : messages]
        requestBody["response_format"] = sentenceSchema(originalLanguage: deviceLanguage,
                                                        translationLanguage: targetLanguage,
                                                        shouldCreateTitle: false)

        let jsonString = try await RequestFactory.makeRequest(type: model, requestBody: requestBody)

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw TranslationServicesError.failedToGetResponseData
        }
        let decoder = JSONDecoder.createChapterResponseDecoder(deviceLanguageKey: deviceLanguage.rawValue, targetLanguageKey: targetLanguage.rawValue)
        let chapterResponse = try decoder.decode(ChapterResponse.self, from: jsonData)
        let passage = chapterResponse.sentences.reduce("") { $0 + $1.original }
        return Chapter(storyId: UUID(),
                       title: chapterResponse.chapterNumberAndTitle ?? "",
                       sentences: chapterResponse.sentences,
                       audioVoice: targetLanguage.voices.first ?? .xiaoxiao,
                       audio: .init(data: Data()),
                       passage: passage,
                       deviceLanguage: deviceLanguage,
                       language: targetLanguage)
    }
}
