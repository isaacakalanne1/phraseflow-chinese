//
//  FlowTaleService.swift
//  FlowTale
//
//  Created by iakalann on 10/09/2024.
//

import Foundation

struct WordDefinition: Codable, Equatable, Hashable {
    let word: String
    let pronunciation: String
    let definition: String
    let definitionInContextOfSentence: String
}

enum FlowTaleServicesError: Error {
    case generalError
    case invalidJSON
    case failedToGetChapter
    case failedToGetDeviceLanguage
    case failedToGetResponseData
    case failedToEncodeJson
    case failedToDecodeJson
    case failedToDecodeSentences
}

enum FluxImageError: Error {
    case missingRequestID
    case missingImageURL
}

/// The request body you’ll send to the moderation endpoint.
struct ModerationRequest: Codable {
    let model: String
    let input: String
}

enum ModerationCategories: CaseIterable {
    case sexual
    case sexualMinors
    case violenceGraphic
    case selfHarmIntent
    case selfHarmInstructions
    case illicitViolent

    /// Human-readable name you want to display in the UI
    var name: String {
        switch self {
        case .sexual:
            return LocalizedString.moderationCategorySexual
        case .sexualMinors:
            return LocalizedString.moderationCategorySexualMinors
        case .violenceGraphic:
            return LocalizedString.moderationCategoryViolenceGraphic
        case .selfHarmIntent:
            return LocalizedString.moderationCategorySelfHarmIntent
        case .selfHarmInstructions:
            return LocalizedString.moderationCategorySelfHarmInstructions
        case .illicitViolent:
            return LocalizedString.moderationCategoryIllicitViolence
        }
    }

    /// Key to use when looking up the category_scores dictionary from the API
    var key: String {
        switch self {
        case .sexual:
            return "sexual"
        case .sexualMinors:
            return "sexual/minors"
        case .violenceGraphic:
            return "violence/graphic"
        case .selfHarmIntent:
            return "self-harm/intent"
        case .selfHarmInstructions:
            return "self-harm/instructions"
        case .illicitViolent:
            return "illicit/violent"
        }
    }

    /// The threshold above which the story fails moderation
    var thresholdScore: Double {
        switch self {
        case .sexual:
            return 0.8
        case .sexualMinors:
            return 0.2
        case .violenceGraphic:
            return 0.7
        case .selfHarmIntent:
            return 0.2
        case .selfHarmInstructions:
            return 0.2
        case .illicitViolent:
            return 0.2
        }
    }
}

/// A single result object in the Moderation API’s response
struct ModerationResult: Codable {
    let flagged: Bool
    let categories: [String: Bool]
    let category_scores: [String: Double]
    let category_applied_input_types: [String: [String]]
}

/// The top-level response from the Moderation API
struct ModerationResponse: Codable {
    let id: String
    let model: String
    let results: [ModerationResult]

    /// Returns `true` if all categories are below threshold
    var didPassModeration: Bool {
        guard let firstResult = results.first else {
            // If no results, consider it “passed” or handle as needed
            return true
        }
        for category in ModerationCategories.allCases {
            // Use category.key, not category.name
            let score = firstResult.category_scores[category.key] ?? 0.0
            if score >= category.thresholdScore {
                return false
            }
        }
        return true
    }

    /// Returns an array of category results (threshold + actual score)
    /// so you can display them in your "Why didn't it pass?" UI.
    var categoryResults: [CategoryResult] {
        guard let firstResult = results.first else {
            return []
        }

        return ModerationCategories.allCases.map { category in
            let score = firstResult.category_scores[category.key] ?? 0.0
            return CategoryResult(
                category: category,
                threshold: category.thresholdScore,
                score: score
            )
        }
    }
}

/// A model that ties together the category, the threshold, and the actual score.
struct CategoryResult: Identifiable {
    let id = UUID()

    let category: ModerationCategories
    let threshold: Double
    let score: Double

    /// Did this particular category pass (score < threshold)?
    var didPass: Bool {
        score < threshold
    }

    /// For easy display in the UI: "80%" or "92%" etc.
    var thresholdPercentageString: String {
        "\(Int(threshold * 100))%"
    }

    var scorePercentageString: String {
        "\(Int(score * 100))%"
    }
}


protocol FlowTaleServicesProtocol {
    func generateStory(story: Story) async throws -> String
    func summarizeStory(story: Story) async throws -> String
    func translateStory(story: Story,
                        storyString: String,
                        deviceLanguage: Language?) async throws -> Story
    func fetchDefinitions(for sentenceIndex: Int,
                          in sentence: Sentence,
                          chapter: Chapter,
                          story: Story,
                          deviceLanguage: Language?) async throws -> [Definition]
    func fetchDefinition(of character: String,
                         withinContextOf sentence: Sentence,
                         story: Story,
                         deviceLanguage: Language?) async throws -> String
    func generateImage(with prompt: String) async throws -> Data
    func moderateText(_ text: String) async throws -> ModerationResponse
}

final class FlowTaleServices: FlowTaleServicesProtocol {

    private let baseURL = "https://queue.fal.run/fal-ai/flux"
    private let apiKey = ProcessInfo.processInfo.environment["FAL_KEY"] ?? "e1f58875-fe36-4a31-ad34-badb6bbd0409:4645ce9820c0b75b3cbe1b0d9c324306"
    private let session = URLSession.shared

    func generateStory(story: Story) async throws -> String {
        do {
            return try await continueStory(story: story)
        } catch {
            throw FlowTaleServicesError.generalError
        }
    }

    func translateStory(story: Story,
                        storyString: String,
                        deviceLanguage: Language?) async throws -> Story {
        do {
            let jsonString = try await convertToJson(story: story,
                                                     storyString: storyString,
                                                     shouldCreateTitle: story.title.isEmpty,
                                                     deviceLanguage: deviceLanguage)
            guard let jsonData = jsonString.data(using: .utf8) else {
                throw FlowTaleServicesError.failedToGetResponseData
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .custom({ (keys) -> CodingKey in
                let lastKey = keys.last!
                guard lastKey.intValue == nil else { return lastKey }
                switch lastKey.stringValue {
                case deviceLanguage?.schemaKey:
                    return AnyKey(stringValue: "original")!
                case story.language.schemaKey:
                    return AnyKey(stringValue: "translation")!
                case "briefLatestStorySummaryIn\(deviceLanguage?.key ?? "English")":
                    return AnyKey(stringValue: "briefLatestStorySummary")!
                case "chapterNumberAndTitleIn\(deviceLanguage?.key ?? "English")":
                    return AnyKey(stringValue: "chapterNumberAndTitle")!
                case "titleOfNovelIn\(deviceLanguage?.key ?? "English")":
                    return AnyKey(stringValue: "titleOfNovel")!
                default:
                    return AnyKey(stringValue: lastKey.stringValue)!
                }
            })
            let chapterResponse = try decoder.decode(ChapterResponse.self, from: jsonData)
            let sentences = chapterResponse.sentences.map(
                {
                    var translation = $0.translation
                    if story.language == .mandarinChinese {
                        translation = translation.replacingOccurrences(of: " ", with: "")
                    }
                    return Sentence(translation: translation, english: $0.original)
                }
            )
            let chapter = Chapter(title: chapterResponse.chapterNumberAndTitle ?? "",
                                  sentences: sentences,
                                  audio: .init(timestamps: [], data: Data()),
                                  passage: storyString)

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

    func fetchDefinitions(for sentenceIndex: Int,
                          in sentence: Sentence,
                          chapter: Chapter,
                          story: Story,
                          deviceLanguage: Language?) async throws -> [Definition]
    {
        // 1. Ensure we have a device language
        guard let deviceLanguage else {
            throw FlowTaleServicesError.failedToGetDeviceLanguage
        }

        let matchingTimestamps = chapter.audio.timestamps.filter {
            $0.sentenceIndex == sentenceIndex
        }

        guard !matchingTimestamps.isEmpty else {
            // No words found for that sentence
            return []
        }

        // 3. Build prompts
        let languageName = story.language.descriptiveEnglishName
        let wordsToDefine = matchingTimestamps.map { $0.word }

        let initialPrompt = """
        You are an AI assistant that provides \(deviceLanguage.displayName) definitions for words in \(languageName) sentences.
        Your explanations are brief and simple.
        """

        let mainPrompt = """
        We have this sentence in \(languageName): "\(sentence.original)".
        The user sees a translation: "\(sentence.translation)".
        Define each of the following words in the context of the above sentence:
        "\(wordsToDefine.joined(separator: "\", \""))"
        """

        let messages: [[String: String]] = [
            ["role": "system", "content": initialPrompt],
            ["role": "user",   "content": mainPrompt]
        ]

        // 4. Make your request body
        let requestBody: [String: Any] = [
            "model": APIRequestType.openAI.modelName,
            "messages": messages,
            "response_format": definitionSchema(),
            // If you're using function-calling:
            // "function_call": ["name": "wordDefinitions"]
        ]

        // 5. Execute the request -> get JSON string back
        let jsonString = try await makeRequest(type: .openAI, requestBody: requestBody)

        // 6. Decode into a temporary struct that holds "words"
        //    (We can define a small container for convenience.)
        struct MultipleWordsResponse: Codable {
            let words: [WordDefinition]
        }

        // Turn JSON string into Data, decode
        guard let data = jsonString.data(using: .utf8) else {
            throw FlowTaleServicesError.invalidJSON
        }

        let multipleWordsResponse = try JSONDecoder().decode(MultipleWordsResponse.self, from: data)

        // 7. We have [WordDefinition].
        //    Now create our final [Definition]—one per word/timeStampData pair.
        //    We assume the order returned by the AI matches the order of `wordsToDefine`.
        let wordDefinitions = multipleWordsResponse.words

        // Just to be safe, ensure counts match (in case the user typed repeated words).
        // If there's a mismatch, handle accordingly; here we just take the min.
        let minCount = min(matchingTimestamps.count, wordDefinitions.count)

        // 8. Map each WordDefinition to your existing Definition structure
        //    We’ll store everything in the `definition` property, combining
        //    the base definition, context, and pronunciation, but you can do
        //    whatever you prefer.
        let finalDefinitions: [Definition] = zip(matchingTimestamps.prefix(minCount),
                                                 wordDefinitions.prefix(minCount))
          .map { (timeStamp, wordDef) -> Definition in
              let fullDefinitionText = """
              🗣️ \(wordDef.pronunciation)
              ✏️ \(wordDef.definition)
              🌎 \(wordDef.definitionInContextOfSentence)
              """
              return Definition(
                  creationDate: Date(),
                  studiedDates: [],
                  timestampData: timeStamp,
                  sentence: sentence,
                  detail: wordDef,
                  definition: fullDefinitionText,
                  language: story.language
              )
          }

        return finalDefinitions
    }

    func fetchDefinition(of character: String,
                         withinContextOf sentence: Sentence,
                         story: Story,
                         deviceLanguage: Language?) async throws -> String {
        guard let deviceLanguage else {
            throw FlowTaleServicesError.failedToGetDeviceLanguage
        }
        let languageName = story.language.descriptiveEnglishName
        let initialPrompt =
"""
        You are an AI assistant that provides \(deviceLanguage.displayName) definitions for characters in \(languageName) sentences. Your explanations are brief, and simple to understand.
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
Write the definition in \(deviceLanguage.displayName).
"""
        let messages: [[String: String]] = [
            ["role": "system", "content": initialPrompt],
            ["role": "user", "content": mainPrompt]
        ]

        let requestBody: [String: Any] = [
            "model": APIRequestType.openAI.modelName,
            "messages": messages
        ]

        return try await makeRequest(type: .openAI, requestBody: requestBody)
    }

    private func continueStory(story: Story) async throws -> String {
        let model: APIRequestType = .openRouter(.metaLlama)
//        let model: APIRequestType = .openAI
        var requestBody: [String: Any] = [
            "model": model.modelName,
        ]

        var messages: [[String: String]] = [
            ["role": "user", "content": "Write an incredible first chapter of a novel in English set in \(story.storyPrompt). \(story.difficulty.vocabularyPrompt)"]
        ]

        for chapter in story.chapters {
            messages.append(["role": "system", "content": chapter.title + "\n" + chapter.passage])
            messages.append(["role": "user", "content": "Write an incredible next chapter of the novel in English with complex, three-dimensional characters. \(story.difficulty.vocabularyPrompt)"])
        }
        requestBody["messages"] = messages

        return try await makeRequest(type: model, requestBody: requestBody)
    }

    func summarizeStory(story: Story) async throws -> String {
        let model: APIRequestType = .openRouter(.metaLlama)
//        let model: APIRequestType = .openAI
        var requestBody: [String: Any] = [
            "model": model.modelName,
        ]

        var messages: [[String: String]] = [
            ["role": "system", "content": "A story will be provided below, which you will write a summary of."]
        ]

        for chapter in story.chapters {
            messages.append(["role": "user", "content": chapter.title + "\n" + chapter.passage])
            messages.append(["role": "user", "content": "Write a summary of the following story in English. The summary should be around 10 sentences."])
        }
        requestBody["messages"] = messages

        return try await makeRequest(type: model, requestBody: requestBody)
    }

    private func convertToJson(story: Story,
                               storyString: String,
                               shouldCreateTitle: Bool,
                               deviceLanguage: Language?) async throws -> String {
        guard let deviceLanguage else {
            throw FlowTaleServicesError.failedToGetDeviceLanguage
        }
        let jsonPrompt = """
Format the following story into JSON. Translate each English sentence into \(deviceLanguage == .english ? "" : "\(deviceLanguage.descriptiveEnglishName) and ") \(story.language.descriptiveEnglishName).
Ensure each sentence entry is for an individual sentence.
Translate the whole sentence, including names and places.
This is chapter \(story.chapters.count + 1)
In the briefLatestStorySummary section of the JSON, don't mention "In chapter X", "In this chapter", or anything similar to this.
"""
        var requestBody: [String: Any] = [
            "model": "gpt-4o-mini-2024-07-18",
        ]

        let messages: [[String: String]] = [
            ["role": "system", "content": jsonPrompt],
            ["role": "user", "content": storyString]
        ]
        requestBody["messages"] = messages
        requestBody["response_format"] = sentenceSchema(originalLanguage: deviceLanguage,
                                                        translationLanguage: story.language,
                                                        shouldCreateTitle: shouldCreateTitle)

        return try await makeRequest(type: .openAI, requestBody: requestBody)
    }

    private func makeRequest(type: APIRequestType, requestBody: [String: Any]) async throws -> String {
        let request = createURLRequest(baseUrl: type.baseUrl, authKey: type.authKey)

        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            throw FlowTaleServicesError.failedToEncodeJson
        }

        let session = createURLSession()

        let (data, _) = try await session.upload(for: request, from: jsonData)
        guard let response = try? JSONDecoder().decode(GPTResponse.self, from: data),
              let responseString = response.choices.first?.message.content else {
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

    /// Generates an image from the given prompt at 1024x512 resolution using the Flux API.
    /// - Parameter prompt: The text prompt describing what to generate.
    /// - Returns: A `Data` fetched from the final URL returned by the queue.
    func generateImage(with prompt: String) async throws -> Data {
        // 1. Submit the request to the queue
        let requestID = try await submitGenerationRequest(prompt: prompt)

        // 2. Poll the request status until it is completed
        try await pollRequestStatus(requestID: requestID)

        // 3. Once completed, fetch the result to get the image URL
        let imageURL = try await fetchResult(requestID: requestID)

        // 4. Download the actual image data
        let (data, _) = try await session.data(from: imageURL)

        return data
    }

    // MARK: - Private Helpers

    /// Sends the prompt and custom dimensions to the Flux API to initiate image generation.
    /// - Parameter prompt: The user prompt.
    /// - Returns: The request_id needed for polling.
    private func submitGenerationRequest(prompt: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/schnell") else {
            throw FlowTaleServicesError.generalError
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Key \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // We fix the image size to 1024x512 as requested
        let payload: [String: Any] = [
            "prompt": "Cover art for the following story:\n\(prompt)",
            "image_size": [
                "width": 1024,
                "height": 512
            ]
        ]

        let uploadData = try JSONSerialization.data(withJSONObject: payload)

        let (responseData, _) = try await session.upload(for: request, from: uploadData)
        let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any]

        guard let requestID = json?["request_id"] as? String else {
            throw FluxImageError.missingRequestID
        }

        return requestID
    }

    /// Polls the request status endpoint until the request is completed.
    /// - Parameter requestID: The ID returned when the generation request was submitted.
    private func pollRequestStatus(requestID: String) async throws {
        // For demonstration, we simply poll every 1 second.
        // For larger images or heavier loads, you might want to poll less frequently or use a backoff strategy.
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
               status == "COMPLETED" {
                return
            }
        }
    }

    /// Fetches the final result of a completed image generation request.
    /// - Parameter requestID: The ID of the completed request.
    /// - Returns: The URL for the generated image.
    private func fetchResult(requestID: String) async throws -> URL {
        guard let url = URL(string: "\(baseURL)/requests/\(requestID)") else {
            fatalError("Invalid result URL") // Or handle gracefully
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Key \(apiKey)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await session.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        // The API returns something like:
        // {
        //   "images": [
        //     {
        //       "url": "<image URL>",
        //       "content_type": "image/jpeg"
        //     }
        //   ],
        //   ...
        // }
        guard
            let images = json?["images"] as? [[String: Any]],
            let urlString = images.first?["url"] as? String,
            let imageURL = URL(string: urlString)
        else {
            throw FluxImageError.missingImageURL
        }

        return imageURL
    }

    /// Example function that sends text to the Moderation API.
    func moderateText(_ text: String) async throws -> ModerationResponse {

        // 1. Construct the request URL.
        guard let url = URL(string: "https://api.openai.com/v1/moderations") else {
            throw URLError(.badURL)
        }

        // 2. Build the HTTP request.
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Replace YOUR_OPENAI_API_KEY with your actual API key, or pass it in as a function parameter.
        request.addValue("Bearer \(APIRequestType.openAI.authKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // 3. Prepare the JSON-encoded request body.
        let moderationRequest = ModerationRequest(
            model: "omni-moderation-latest",  // or "text-moderation-latest"
            input: text
        )
        request.httpBody = try JSONEncoder().encode(moderationRequest)

        // 4. Execute the network call using URLSession with async/await.
        let (data, response) = try await URLSession.shared.data(for: request)

        // 5. Check the HTTP response status.
        guard
            let httpResponse = response as? HTTPURLResponse,
            (200..<300).contains(httpResponse.statusCode)
        else {
            throw URLError(.badServerResponse)
        }

        // 6. Decode the JSON response into our `ModerationResponse` struct.
        let moderationResponse = try JSONDecoder().decode(ModerationResponse.self, from: data)

        return moderationResponse
    }
}
