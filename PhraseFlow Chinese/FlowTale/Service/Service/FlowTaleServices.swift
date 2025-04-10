//
//  FlowTaleServices.swift
//  FlowTale
//
//  Created by iakalann on 10/09/2024.
//

import Foundation

final class FlowTaleServices: FlowTaleServicesProtocol {
    private let baseURL = "https://queue.fal.run/fal-ai/flux"
    private let apiKey = ProcessInfo.processInfo.environment["FAL_KEY"] ?? "e1f58875-fe36-4a31-ad34-badb6bbd0409:4645ce9820c0b75b3cbe1b0d9c324306"
    private let session = URLSession.shared

    func generateStory(story: Story,
                       deviceLanguage: Language?) async throws -> Story
    {
        do {
            guard let deviceLanguage else {
                throw FlowTaleServicesError.failedToGetDeviceLanguage
            }
            let jsonString = try await generateStoryRequest(story: story,
                                                            deviceLanguage: deviceLanguage)
            guard let jsonData = jsonString.data(using: .utf8) else {
                throw FlowTaleServicesError.failedToGetResponseData
            }
            let decoder = JSONDecoder.createChapterResponseDecoder(deviceLanguage: deviceLanguage, targetLanguage: story.language)
            let chapterResponse = try decoder.decode(ChapterResponse.self, from: jsonData)
            let passage = chapterResponse.sentences.reduce("") { $0 + $1.original }
            let chapter = Chapter(title: chapterResponse.chapterNumberAndTitle ?? "",
                                  sentences: chapterResponse.sentences,
                                  audio: .init(data: Data()),
                                  passage: passage)

            var story = story
            if story.chapters.isEmpty {
                story.chapters = [chapter]
            } else {
                story.chapters.append(chapter)
            }

            if let title = chapterResponse.titleOfNovel {
                story.title = title
            }
            story.briefLatestStorySummary = chapterResponse.briefLatestStorySummary
            story.currentChapterIndex = story.chapters.count - 1
            story.lastUpdated = .now
            return story
        } catch {
            throw FlowTaleServicesError.failedToDecodeSentences
        }
    }

    func fetchDefinitions(in sentence: Sentence?,
                          story: Story,
                          deviceLanguage: Language) async throws -> [Definition]
    {
        let model = APIRequestType.openRouter(.geminiFlash)

        guard let sentence,
              !sentence.timestamps.isEmpty else {
            throw FlowTaleServicesError.failedToGetTimestamps
        }

        let systemPrompt = """
        You are an AI assistant that provides \(deviceLanguage.displayName) definitions for words in \(story.language.descriptiveEnglishName) sentences.
        """

        let userPrompt = """
        We have this sentence in \(story.language.descriptiveEnglishName): "\(sentence.original)".
        The user sees a translation: "\(sentence.translation)".
        Define each of the following words in the context of the above sentence:
        "\(sentence.timestamps.map { $0.word }.joined(separator: "\", \""))"
        For the definitionInContextOfSentence part of the JSON, define the word in the context of the sentence.
        """

        let requestBody: [String: Any] = [
            "messages": createMessages(systemPrompt: systemPrompt, userPrompt: userPrompt),
            "response_format": definitionSchema()
        ]

        let jsonString = try await makeRequest(type: model, requestBody: requestBody)

        struct MultipleWordsResponse: Codable {
            let words: [WordDefinition]
        }

        guard let data = jsonString.data(using: .utf8) else {
            throw FlowTaleServicesError.invalidJSON
        }

        let multipleWordsResponse = try JSONDecoder().decode(MultipleWordsResponse.self, from: data)

        let wordDefinitions = multipleWordsResponse.words

        let minCount = min(sentence.timestamps.count, wordDefinitions.count)

        let finalDefinitions: [Definition] = zip(sentence.timestamps.prefix(minCount),
                                                 wordDefinitions.prefix(minCount))
            .map { timeStamp, wordDef -> Definition in
                return Definition(
                    timestampData: timeStamp,
                    sentence: sentence,
                    detail: wordDef,
                    language: story.language
                )
            }

        return finalDefinitions
    }

    private func generateStoryRequest(story: Story,
                                      deviceLanguage: Language?) async throws -> String
    {
        guard let deviceLanguage else {
            throw FlowTaleServicesError.failedToGetDeviceLanguage
        }
        var messages: [[String: String]] = []
        var initialPrompt = """
        Write an incredible first chapter of a story written in \(story.language.descriptiveEnglishName).
        
        """
        var furtherPrompt = """
        Write an incredible next chapter of a story written in \(story.language.descriptiveEnglishName).
        
        """
        if let storyPrompt = story.storyPrompt {
            let settingPrompt = "The story is in the following setting: \(storyPrompt)"
            initialPrompt.append(settingPrompt)
            furtherPrompt.append(settingPrompt)
        }

        let promptDetails = """
        
        \(story.difficulty.vocabularyPrompt).
        Use a vocabulary of around 150 \(story.language.descriptiveEnglishName) words.
        The chapter should be around 400 \(story.language.descriptiveEnglishName) words long.
        
        """
        initialPrompt.append(promptDetails)
        furtherPrompt.append(promptDetails)

        messages.append(["role": "user", "content": initialPrompt])
        for chapter in story.chapters.suffix(20) {
            messages.append(["role": "system", "content": chapter.title + "\n" + chapter.passage])
            messages.append(["role": "user", "content": furtherPrompt])
        }
        var requestBody: [String: Any] = ["messages": messages]
        requestBody["response_format"] = sentenceSchema(originalLanguage: deviceLanguage,
                                                        translationLanguage: story.language,
                                                        shouldCreateTitle: story.title.isEmpty)

        return try await makeRequest(type: APIRequestType.openRouter(.geminiFlash),
                                     requestBody: requestBody)
    }

    private func createMessages(systemPrompt: String? = nil,
                                userPrompt: String? = nil,
                                additionalMessages: [[String : String]]? = nil) -> [[String: String]] {
        var messages: [[String: String]] = []
        if let systemPrompt {
            messages.append(["role": "system", "content": systemPrompt])
        }
        if let userPrompt {
            messages.append(["role": "user", "content": userPrompt])
        }
        if let additionalMessages {
            messages.append(contentsOf: additionalMessages)
        }
        return messages
    }

    private func makeRequest(type: APIRequestType, requestBody: [String: Any]) async throws -> String {
        let request = createURLRequest(baseUrl: type.baseUrl, authKey: type.authKey)
        var requestBody = requestBody
        requestBody["model"] = type.modelName

        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            throw FlowTaleServicesError.failedToEncodeJson
        }

        let session = createURLSession()

        let (data, _) = try await session.upload(for: request, from: jsonData)
        guard let response = try? JSONDecoder().decode(GPTResponse.self, from: data),
              let responseString = response.choices.first?.message.content
        else {
            throw FlowTaleServicesError.failedToDecodeJson
        }
        return responseString
    }

    private func createURLRequest(baseUrl: String, authKey: String) -> URLRequest {
        var request = URLRequest(url: URL(string: baseUrl)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    private func createURLSession() -> URLSession {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 1200
        sessionConfig.timeoutIntervalForResource = 1200
        return URLSession(configuration: sessionConfig)
    }

    func generateImage(with prompt: String) async throws -> Data {
        let requestID = try await submitGenerationRequest(prompt: prompt)

        try await pollRequestStatus(requestID: requestID)

        let imageURL = try await fetchResult(requestID: requestID)

        let (data, _) = try await session.data(from: imageURL)

        return data
    }

    private func submitGenerationRequest(prompt: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/schnell") else {
            throw FlowTaleServicesError.generalError
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Key \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "prompt": "Cover art for the following story:\n\(prompt)",
            "image_size": [
                "width": 1024,
                "height": 512,
            ],
        ]

        let uploadData = try JSONSerialization.data(withJSONObject: payload)

        let (responseData, _) = try await session.upload(for: request, from: uploadData)
        let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any]

        guard let requestID = json?["request_id"] as? String else {
            throw FluxImageError.missingRequestID
        }

        return requestID
    }

    private func pollRequestStatus(requestID: String) async throws {
        while true {
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

            guard let url = URL(string: "\(baseURL)/requests/\(requestID)/status") else {
                fatalError("Invalid status URL") // Or handle gracefully
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Key \(apiKey)", forHTTPHeaderField: "Authorization")

            let (data, _) = try await session.data(for: request)
            let statusJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

            // If the status is "completed", break out of the loop
            if let status = statusJSON?["status"] as? String,
               status == "COMPLETED"
            {
                return
            }
        }
    }

    private func fetchResult(requestID: String) async throws -> URL {
        guard let url = URL(string: "\(baseURL)/requests/\(requestID)") else {
            fatalError("Invalid result URL") // Or handle gracefully
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Key \(apiKey)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await session.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        guard
            let images = json?["images"] as? [[String: Any]],
            let urlString = images.first?["url"] as? String,
            let imageURL = URL(string: urlString)
        else {
            throw FluxImageError.missingImageURL
        }

        return imageURL
    }

    func moderateText(_ text: String) async throws -> ModerationResponse {
        guard let url = URL(string: "https://api.openai.com/v1/moderations") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        request.addValue("Bearer \(APIRequestType.openAI.authKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let moderationRequest = ModerationRequest(
            model: "omni-moderation-latest",
            input: text
        )
        request.httpBody = try JSONEncoder().encode(moderationRequest)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard
            let httpResponse = response as? HTTPURLResponse,
            (200 ..< 300).contains(httpResponse.statusCode)
        else {
            throw URLError(.badServerResponse)
        }

        let moderationResponse = try JSONDecoder().decode(ModerationResponse.self, from: data)

        return moderationResponse
    }

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

        let jsonString = try await makeRequest(type: model, requestBody: requestBody)

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

        let jsonString = try await makeRequest(type: model, requestBody: requestBody)

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
