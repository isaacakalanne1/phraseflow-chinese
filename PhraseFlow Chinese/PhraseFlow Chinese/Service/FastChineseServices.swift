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
    func generateStory(categories: [Category]) async throws -> Story
    func generateChapter(using info: Story) async throws -> [Sentence]
    func fetchDefinition(of character: String, withinContextOf sentence: String) async throws -> GPTResponse
}

final class FastChineseServices: FastChineseServicesProtocol {

    func generateStory(categories: [Category]) async throws -> Story {
        let subjects = Subject.allCases.map { $0.title }.shuffled()[0...2]
        let categoryTitles = categories.map { $0.title }
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestData = DefineCharacterRequest(messages: [
            .init(role: "system",
                  content: """
                  You are the greatest Mandarin Chinese storywriter alive, who takes great pleasure in creating Mandarin stories.
                  """),
            .init(role: "user",
                  content: """
        Write a captivating, emotional, and dramatic story, with each sentence split in the same structure as the list above.
        The story should be amazing and captivating, and the reader should be amazed an AI came up with it.
        The story should be full of calming, enjoyable highs and incredibly low lows, always keeping the reader absolutely hooked to find out what will happen next.
        Stay away from subjects which are sensitive in Mainland China, such as Hong Kong, Taiwan, and any other potentially sensitive subjects.

        These are the categories for the story:
        \(categoryTitles)

        These are the central subjects of the story:
        \(subjects)

        Write a summary of the story, then a summary of each of the 10 chapters.
        Write the data in the following JSON format:
        { "storyOverview": "Story summary and summary of 10 chapters", "chapterSummaryList": ["List of descriptions for each chapter"] "difficulty": "HSK1", "title": "Story title", "description": "2 line story description, which does not spoil the overall plot" }
        Keep "chapters" as an empty list, like []
        Do not include the ```json prefix tag or or ``` suffix tag in your response.
        """)
        ])

        guard let jsonData = try? JSONEncoder().encode(requestData) else {
            throw FastChineseServicesError.failedToEncodeJson
        }

        let (data, _) = try await URLSession.shared.upload(for: request, from: jsonData)
        guard let response = try? JSONDecoder().decode(GPTResponse.self, from: data) else {
            throw FastChineseServicesError.failedToDecodeJson
        }

        guard let storyData = response.choices.first?.message.content.data(using: .utf8) else {
            throw FastChineseServicesError.failedToGetResponseData
        }

        guard let story = try? JSONDecoder().decode(Story.self, from: storyData) else {
            throw FastChineseServicesError.failedToDecodeJson
        }
        return story
    }

    func generateChapter(using story: Story) async throws -> [Sentence] {
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestData = DefineCharacterRequest(messages: [
            .init(role: "system",
                  content: """
                                    You are the greatest Mandarin Chinese storywriter alive, who takes great pleasure in creating Mandarin stories. You write stories to help people learn Mandarin Chinese. You output only the expected story in JSON format, with each sentence split into entries in the list.
                                    You output no explaining text before or after the JSON, only the JSON.
                                    You output data in the following format: [ { "mandarin": "你好", "pinyin": ["nǐ", "hǎo"], "english": "Hello" }, { "mandarin": "谢谢", "pinyin": ["xiè", "xie"], "english": "Thank you" }, { "mandarin": "再见", "pinyin": ["zài", "jiàn"], "english": "Goodbye" } ]
                                    You are a master at pinyin and write the absolute best, most accurate tone markings for the pinyin, based on context, and including all relevant neutral tones.
                                    Separate each pinyin in the list into their individual sounds. For example, "níanqīng" would be separated into ["nían", "qīng"]
                                    Include punctuation in the pinyin, to match the Mandarin, such as commas, and full stops. The punctuation should be its own item in the pinyin list, such as ["nǐ", "，"]. Use Mandarin punctuation.
                                    Do not include the ```json prefix tag or or ``` suffix tag in your response.
                                    """),
            .init(role: "user",
                  content: """
        Generate a captivating, emotional, and extremely engaging story, with each sentence split in the same structure as the list above.
        The story should be amazing and captivating, and the reader should be amazed an AI came up with it.
        The story should be full of calming, enjoyable highs and incredibly low lows, always keeping the reader absolutely hooked to find out what will happen next.
        Stay away from subjects which are sensitive in Mainland China, such as Hong Kong, Taiwan, and any other potentially sensitive subjects.
        This is the description of the story:
        \(story.storyOverview)

        Generate chapter \(story.chapters.count + 1) from the list. The chapter should be 20-30 lines long.

        Write the story using \(story.difficulty.title) vocabulary. Use only vocabulary for someone that is at this level, considering HSK1 is absolute beginner, like a 5 year old, and HSK5 is an absolute expert, like a PhD student.

        Feel free to use the same words often, in order to help the user learn the Mandarin words better.
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

        let (data, _) = try await URLSession.shared.upload(for: request, from: jsonData)
        guard let response = try? JSONDecoder().decode(GPTResponse.self, from: data) else { // TODO: May need to update decode type to array, depending on API documentation
            throw FastChineseServicesError.failedToDecodeJson
        }
        return response
    }
}
