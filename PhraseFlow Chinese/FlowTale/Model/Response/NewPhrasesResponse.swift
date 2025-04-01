//
//  GPTResponse.swift
//  FlowTale
//
//  Created by iakalann on 11/09/2024.
//

import Foundation

struct GPTResponse: Codable {
    var choices: [ChoiceResponse]

    struct ChoiceResponse: Codable {
        var message: MessageResponse

        struct MessageResponse: Codable {
            var content: String
        }
    }
}
