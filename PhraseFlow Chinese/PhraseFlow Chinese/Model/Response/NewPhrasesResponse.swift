//
//  GPTResponse.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 11/09/2024.
//

import Foundation

struct GPTResponse: Codable { // TODO: Update this to match OpenAI API
    var choices: [ChoiceResponse]

    struct ChoiceResponse: Codable {
        var message: MessageResponse

        struct MessageResponse: Codable {
            var content: String // TODO: Update to be [Phrase] directly
        }
    }

    func decodedPhrases(category: PhraseCategory) -> [Phrase]? {
        guard let content = choices.first?.message.content else { return nil }

        // Clean the string
        let cleanedContent = content
            .replacingOccurrences(of: "\\'", with: "'")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\\", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Convert the cleaned string to data and decode
        guard let data = cleanedContent.data(using: .utf8) else { return nil }

        do {
            return try JSONDecoder()
                .decode([Phrase].self, from: data)
                .map {
                    Phrase(mandarin: $0.mandarin, pinyin: $0.pinyin, english: $0.english, category: category)
                }
        } catch {
            print("Failed to decode: \(error)")
            return nil
        }
    }
}
