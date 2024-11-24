//
//  FastChineseService.swift
//  FastChinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation

enum FastChineseServicesError: Error {
    case failedToGetResponseData
    case failedToEncodeJson
    case failedToDecodeJson
    case failedToDecodeSentences
}

protocol FastChineseServicesProtocol {
    func generateStory(story: Story?, settings: SettingsState) async throws -> Story
    func fetchDefinition(of character: String, withinContextOf sentence: Sentence, settings: SettingsState) async throws -> String
}

final class FastChineseServices: FastChineseServicesProtocol {

    func generateStory(story: Story?, settings: SettingsState) async throws -> Story {
        do {
            let (response, setting) = try await continueStory(story: story, settings: settings)
            let jsonString = try await convertToJson(mandarin: response,
                                                     settings: settings,
                                                     shouldCreateTitle: story == nil)
            guard let jsonData = jsonString.data(using: .utf8) else {
                throw FastChineseServicesError.failedToGetResponseData
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .custom({ (keys) -> CodingKey in
                let lastKey = keys.last!
                guard lastKey.intValue == nil else { return lastKey }
                if lastKey.stringValue == settings.language.schemaKey {
                    return AnyKey(stringValue: "translation")!
                }
                return AnyKey(stringValue: lastKey.stringValue)!
            })
            let chapterResponse = try decoder.decode(ChapterResponse.self, from: jsonData)
            let sentences = chapterResponse.sentences.map({
                var translation = $0.translation
                if settings.language == .mandarinChinese {
                    translation = translation.replacingOccurrences(of: " ", with: "")
                }
                return Sentence(translation: translation, english: $0.english) })
            let chapter = Chapter(title: chapterResponse.chapterNumberAndTitleInEnglish ?? "", sentences: sentences)

            if var story {
                if story.chapters.isEmpty {
                    story.chapters = [chapter]
                } else {
                    story.chapters.append(chapter)
                }
                story.briefLatestStorySummaryinEnglish = chapterResponse.briefLatestStorySummaryinEnglish
                story.currentChapterIndex = story.chapters.count - 1
                story.lastUpdated = .now
                return story
            } else {
                return Story(briefLatestStorySummaryinEnglish: chapterResponse.briefLatestStorySummaryinEnglish,
                             difficulty: .beginner,
                             language: settings.language,
                             title: chapterResponse.titleOfNovel ?? "",
                             chapters: [chapter],
                             setting: setting)
            }
        } catch {
            throw FastChineseServicesError.failedToDecodeSentences
        }
    }

    func fetchDefinition(of character: String, withinContextOf sentence: Sentence, settings: SettingsState) async throws -> String {
        let languageName = settings.language.name
        let initialPrompt =
"""
        You are an AI assistant that provides English definitions for characters in \(languageName) sentences. Your explanations are brief, and simple to understand.
        You provide the pronounciation for the \(languageName) character in brackets after the Chinese character.
        If the character is used as part of a larger word, you also provide the pronounciation and definition for each character in this overall word.
        You also provide the definition of the word in the context of the overall sentence.
        You never repeat the Chinese sentence, and never translate the whole of the Chinese sentence into English.
"""
        let mainPrompt =
"""
        Provide a definition for this word: "\(character)"
        If the word is made of different characters, also provide brief definitions for each of the characters in the word.
        Also explain the word in the context of the sentence: "\(sentence.translation)".
        Don't define other words in the sentence.
"""
        let messages: [[String: String]] = [
            ["role": "system", "content": initialPrompt],
            ["role": "user", "content": mainPrompt]
        ]

        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini-2024-07-18",
            "messages": messages
        ]

        return try await makeOpenAIRequest(requestBody: requestBody)
    }

    private func continueStory(story: Story?, settings: SettingsState) async throws -> (String, StorySetting) {
        let setting = (story?.setting ?? StorySetting.allCases.randomElement()) ?? StorySetting.medieval
        var initialPrompt = "Write an incredible first chapter of a novel set in \(setting.settingName). Use \(settings.language.name) names for characters and places."
        var vocabularyPrompt = ""
        switch story?.difficulty ?? settings.difficulty {
        case .beginner:
            vocabularyPrompt = " Use extremely simple sentence structures and words, and very short sentences."
        case .intermediate:
            vocabularyPrompt = " Use very simple sentence structures and words, and short sentences."
        case .advanced:
            vocabularyPrompt = " Use simple words."
        case .expert:
            break
        }
        initialPrompt.append(vocabularyPrompt)

        let qualityPrompt = """

The chapter should have complex, three-dimensional, flawed characters.
The chapter should also be long, around 30 sentences.
Use quotation marks for speech.
"""
        initialPrompt.append(qualityPrompt)
        var requestBody: [String: Any] = [
            "model": "meta-llama/llama-3.2-90b-vision-instruct",
        ]

        var messages: [[String: String]] = [["role": "user", "content": initialPrompt]]
        if let chapters = story?.chapters {
            var continueStoryPrompt = "Write an incredible next chapter of the novel. Use \(settings.language.name) names for characters and places."
            continueStoryPrompt.append(vocabularyPrompt)
            continueStoryPrompt.append(qualityPrompt)
            for chapter in chapters {
                messages.append(["role": "system", "content": chapter.title + "\n" + chapter.passage])
                messages.append(["role": "user", "content": continueStoryPrompt])
            }
        }
        requestBody["messages"] = messages

        return (try await makeOpenrouterRequest(requestBody: requestBody), setting)
    }

    private func convertToJson(mandarin: String, settings: SettingsState, shouldCreateTitle: Bool) async throws -> String {

        let jsonPrompt = """
Format the following story into JSON. Translate each English sentence into \(settings.language.name).
"""
        var requestBody: [String: Any] = [
            "model": "gpt-4o-mini-2024-07-18",
        ]

        let messages: [[String: String]] = [
            ["role": "system", "content": jsonPrompt],
            ["role": "user", "content": mandarin]
        ]
        requestBody["messages"] = messages
        requestBody["response_format"] = sentenceSchema(languageKey: settings.language.schemaKey,
                                                        shouldCreateTitle: shouldCreateTitle)

        return try await makeOpenAIRequest(requestBody: requestBody)
    }

    private func makeOpenrouterRequest(requestBody: [String: Any]) async throws -> String {

        var request = URLRequest(url: URL(string: "https://openrouter.ai/api/v1/chat/completions")!)
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

struct AnyKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}
