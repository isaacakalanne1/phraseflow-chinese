//
//  GPTResponse.swift
//  FastChinese
//
//  Created by iakalann on 11/09/2024.
//

import Foundation

struct GPTResponse: Codable { // TODO: Update this to match OpenAI API
    var choices: [ChoiceResponse]

    struct ChoiceResponse: Codable {
        var message: MessageResponse

        struct MessageResponse: Codable {
            var content: String // TODO: Update to be [Sentence] directly
        }
    }

    func decodedSentences() -> [Sentence]? {
//        guard let content = choices.first?.message.content else { return nil }

        // Convert the cleaned string to data and decode
        guard let data = choices.first?.message.content.data(using: .utf8) else { return nil }

        do {
            return try JSONDecoder()
                .decode([Sentence].self, from: data)
        } catch {
            print("Failed to decode: \(error)")
            return nil
        }
    }
}
