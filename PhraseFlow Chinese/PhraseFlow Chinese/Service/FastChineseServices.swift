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
    func fetchDefinition(of character: String, withinContextOf sentence: Sentence, story: Story?, settings: SettingsState) async throws -> String
}

final class FastChineseServices: FastChineseServicesProtocol {

    func generateStory(story: Story?, settings: SettingsState) async throws -> Story {
        let translationLanguage = story?.language ?? settings.language
        let originalLanguage = Language.allCases.first(where: { $0.identifier == Locale.current.language.languageCode?.identifier })
        do {
            let storyPrompt = StoryPrompts.all.randomElement() ?? "a medieval town"
            let response = try await continueStory(story: story,
                                                   storyPrompt: storyPrompt,
                                                   settings: settings)
            let jsonString = try await convertToJson(story: story,
                                                     translation: response,
                                                     settings: settings,
                                                     shouldCreateTitle: story == nil)
            guard let jsonData = jsonString.data(using: .utf8) else {
                throw FastChineseServicesError.failedToGetResponseData
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .custom({ (keys) -> CodingKey in
                let lastKey = keys.last!
                guard lastKey.intValue == nil else { return lastKey }
                if lastKey.stringValue == originalLanguage?.schemaKey {
                    return AnyKey(stringValue: "original")!
                } else if lastKey.stringValue == translationLanguage.schemaKey {
                    return AnyKey(stringValue: "translation")!
                } else if lastKey.stringValue == "briefLatestStorySummaryIn\(originalLanguage?.key ?? "English")" {
                    return AnyKey(stringValue: "briefLatestStorySummary")!
                } else if lastKey.stringValue == "chapterNumberAndTitleIn\(originalLanguage?.key ?? "English")" {
                    return AnyKey(stringValue: "chapterNumberAndTitle")!
                } else if lastKey.stringValue == "titleOfNovelIn\(originalLanguage?.key ?? "English")" {
                    return AnyKey(stringValue: "titleOfNovel")!
                }
                return AnyKey(stringValue: lastKey.stringValue)!
            })
            let chapterResponse = try decoder.decode(ChapterResponse.self, from: jsonData)
            let sentences = chapterResponse.sentences.map({
                var translation = $0.translation
                if settings.language == .mandarinChinese {
                    translation = translation.replacingOccurrences(of: " ", with: "")
                }
                return Sentence(translation: translation, english: $0.original) })
            let chapter = Chapter(title: chapterResponse.chapterNumberAndTitle ?? "", sentences: sentences)

            if var story {
                if story.chapters.isEmpty {
                    story.chapters = [chapter]
                } else {
                    story.chapters.append(chapter)
                }
                story.briefLatestStorySummary = chapterResponse.briefLatestStorySummary
                story.currentChapterIndex = story.chapters.count - 1
                story.lastUpdated = .now
                return story
            } else {
                return Story(briefLatestStorySummary: chapterResponse.briefLatestStorySummary,
                             difficulty: .beginner,
                             language: settings.language,
                             title: chapterResponse.titleOfNovel ?? "",
                             chapters: [chapter],
                             storyPrompt: storyPrompt)
            }
        } catch {
            throw FastChineseServicesError.failedToDecodeSentences
        }
    }

    func fetchDefinition(of character: String, withinContextOf sentence: Sentence, story: Story?, settings: SettingsState) async throws -> String {
        let originalLanguage = Language.allCases.first(where: { $0.identifier == Locale.current.language.languageCode?.identifier })
        let languageName = story?.language.descriptiveEnglishName ?? settings.language.descriptiveEnglishName
        let initialPrompt =
"""
        You are an AI assistant that provides \(originalLanguage?.displayName ?? "English") definitions for characters in \(languageName) sentences. Your explanations are brief, and simple to understand.
        You provide the pronounciation for the \(languageName) character in brackets after the \(languageName) word.
        If the character is used as part of a larger word, you also provide the pronounciation and definition for each character in this overall word.
        You also provide the definition of the word in the context of the overall sentence.
        You never repeat the \(languageName) sentence, and never translate the whole of the \(languageName) sentence into English.
"""
        let mainPrompt =
"""
Provide a definition for this word: "\(character)"
Also explain the word in the context of the sentence: "\(sentence.translation)".
Don't define other words in the sentence.
Write the definition in \(originalLanguage?.displayName ?? "English").
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

    private func continueStory(story: Story?, storyPrompt: String, settings: SettingsState) async throws -> String {
        var initialPrompt = "Write an incredible first chapter of a novel in English with complex, three-dimensional characters set in \(story?.storyPrompt ?? storyPrompt). "
        var vocabularyPrompt = ""
        switch story?.difficulty ?? settings.difficulty {
        case .beginner:
            vocabularyPrompt = "Use extremely basic, simple words and extremely short sentences."
        case .intermediate:
            vocabularyPrompt = "Use basic, simple words and short sentences."
        case .advanced:
            vocabularyPrompt = "Use simple words and medium length sentences."
        case .expert:
            break
        }
        initialPrompt.append(vocabularyPrompt)

        var requestBody: [String: Any] = [
            "model": "meta-llama/llama-3.3-70b-instruct",
        ]

        var messages: [[String: String]] = [["role": "user", "content": initialPrompt]]
        if let chapters = story?.chapters {
            var continueStoryPrompt = "Write an incredible next chapter of the novel in English with complex, three-dimensional characters. "
            continueStoryPrompt.append(vocabularyPrompt)
            for chapter in chapters {
                messages.append(["role": "system", "content": chapter.title + "\n" + chapter.passage])
                messages.append(["role": "user", "content": continueStoryPrompt])
            }
        }
        requestBody["messages"] = messages

        return try await makeOpenrouterRequest(requestBody: requestBody)
    }

    private func convertToJson(story: Story?, translation: String, settings: SettingsState, shouldCreateTitle: Bool) async throws -> String {
        let originalLanguage = Language.allCases.first(where: { $0.identifier == Locale.current.language.languageCode?.identifier }) ?? .english
        let translationLanguage = story?.language ?? settings.language

        let jsonPrompt = """
Format the following story into JSON. Translate each English sentence into \(originalLanguage == .english ? "" : "\(originalLanguage.descriptiveEnglishName) and ") \(translationLanguage.descriptiveEnglishName).
Ensure each sentence entry is for an individual sentence.
Translate the whole sentence, including names and places.
"""
        var requestBody: [String: Any] = [
            "model": "gpt-4o-mini-2024-07-18",
        ]

        let messages: [[String: String]] = [
            ["role": "system", "content": jsonPrompt],
            ["role": "user", "content": translation]
        ]
        requestBody["messages"] = messages
        requestBody["response_format"] = sentenceSchema(originalLanguage: originalLanguage,
                                                        translationLanguage: translationLanguage,
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
