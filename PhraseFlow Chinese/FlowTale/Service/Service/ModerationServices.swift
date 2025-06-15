//
//  ModerationServices.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation

class ModerationServices: ModerationServicesProtocol {
    func moderateText(_ text: String) async throws -> ModerationResponse {
        guard let url = URL(string: "https://api.openai.com/v1/moderations") else {
            throw URLError(.badURL)
        }

        var request = RequestFactory.createURLRequest(
            baseUrl: "https://api.openai.com/v1/moderations",
            authKey: APIRequestType.openAI.authKey
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
