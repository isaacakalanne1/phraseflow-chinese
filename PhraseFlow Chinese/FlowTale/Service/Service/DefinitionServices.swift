//
//  DefinitionServices.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation

class DefinitionServices: DefinitionServicesProtocol {
    func fetchDefinitions(in sentence: Sentence?,
                          story: Story,
                          deviceLanguage: Language) async throws -> [Definition] {
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
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "response_format": definitionSchema()
        ]

        let jsonString = try await RequestFactory.makeRequest(type: .openRouter(.geminiFlash), requestBody: requestBody)

        guard let data = jsonString.data(using: .utf8) else {
            throw FlowTaleServicesError.invalidJSON
        }

        let multipleWordsResponse = try JSONDecoder().decode(MultipleWordsResponse.self, from: data)

        let minCount = min(sentence.timestamps.count,
                           multipleWordsResponse.words.count)

        return zip(sentence.timestamps.prefix(minCount),
                   multipleWordsResponse.words.prefix(minCount))
        .map { timeStamp, wordDef -> Definition in
            return Definition(
                timestampData: timeStamp,
                sentence: sentence,
                detail: wordDef,
                language: story.language
            )
        }
    }
}
