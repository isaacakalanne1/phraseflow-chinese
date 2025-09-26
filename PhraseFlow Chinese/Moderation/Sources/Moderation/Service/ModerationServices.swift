//
//  ModerationServices.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation
import APIRequest

public class ModerationServices: ModerationServicesProtocol {
    public init() {}
    
    public func moderateText(_ text: String) async throws -> ModerationResponse {
        let authKey = try await APIRequestType.openAI.authKey()
        var request = RequestFactory.createURLRequest(
            baseUrl: "https://api.openai.com/v1/moderations",
            authKey: authKey
        )

        request.httpBody = try JSONEncoder()
            .encode(ModerationRequest(model: "omni-moderation-latest",
                                      input: text))

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
}
