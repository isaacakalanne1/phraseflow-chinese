//
//  TranslationServices.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation

class TranslationServices: TranslationServicesProtocol {
    func translateText(
        _ text: String,
        from deviceLanguage: Language?,
        to targetLanguage: Language
    ) async throws -> Chapter {
        let model = APIRequestType.openRouter(.geminiFlash)
        guard let deviceLanguage else {
            throw FlowTaleServicesError.failedToGetDeviceLanguage
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
            throw FlowTaleServicesError.failedToGetResponseData
        }
        let decoder = JSONDecoder.createChapterResponseDecoder(deviceLanguage: deviceLanguage, targetLanguage: targetLanguage)
        let chapterResponse = try decoder.decode(ChapterResponse.self, from: jsonData)
        let passage = chapterResponse.sentences.reduce("") { $0 + $1.original }
        return Chapter(title: chapterResponse.chapterNumberAndTitle ?? "",
                       sentences: chapterResponse.sentences,
                       audio: .init(data: Data()),
                       passage: passage)
    }

    func breakdownText(
        _ text: String,
        textLanguage: Language,
        deviceLanguage: Language
    ) async throws -> Chapter {
        let model = APIRequestType.openRouter(.geminiFlash)

        let prompt = """
        Break down the following \(textLanguage.descriptiveEnglishName) text into individual sentences.
        For each sentence, provide:
        1. The original sentence in \(textLanguage.descriptiveEnglishName)
        2. A translation of that sentence to \(deviceLanguage.descriptiveEnglishName)
        
        Maintain the meaning and cultural context as accurately as possible.
        
        Text to break down:
        \(text)
        """
        let messages: [[String: String]] = [["role": "system", "content": prompt]]
        var requestBody: [String: Any] = ["messages" : messages]
        requestBody["response_format"] = sentenceSchema(originalLanguage: textLanguage,
                                                        translationLanguage: deviceLanguage,
                                                        shouldCreateTitle: false)

        let jsonString = try await RequestFactory.makeRequest(type: model, requestBody: requestBody)

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw FlowTaleServicesError.failedToGetResponseData
        }
        let decoder = JSONDecoder.createChapterResponseDecoder(deviceLanguage: textLanguage, targetLanguage: deviceLanguage)
        let chapterResponse = try decoder.decode(ChapterResponse.self, from: jsonData)
        let passage = chapterResponse.sentences.reduce("") { $0 + $1.original }
        return Chapter(title: chapterResponse.chapterNumberAndTitle ?? "",
                       sentences: chapterResponse.sentences,
                       audio: .init(data: Data()),
                       passage: passage)
    }
}
