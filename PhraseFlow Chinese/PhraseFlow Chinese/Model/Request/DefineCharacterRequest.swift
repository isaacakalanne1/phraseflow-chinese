//
//  DefineCharacterRequest.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation

struct DefineCharacterRequest: Codable {
    var model = "gpt-4o-mini-2024-07-18"
    var messages: [MessageBody]

    struct MessageBody: Codable {
        var role: String
        var content: String
    }
}
