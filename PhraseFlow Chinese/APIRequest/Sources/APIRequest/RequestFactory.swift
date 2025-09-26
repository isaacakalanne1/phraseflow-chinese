//
//  RequestFactory.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation

enum RequestFactoryError: Error {
    case failedToEncodeJson
    case failedToDecodeJson
}

public class RequestFactory {
    public static func makeRequest(
        type: APIRequestType,
        requestBody: [String: Any]
    ) async throws -> String {
        let authKey = try await type.authKey()
        let request = createURLRequest(baseUrl: type.baseUrl, authKey: authKey)
        var requestBody = requestBody
        requestBody["model"] = type.modelName

        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            throw RequestFactoryError.failedToEncodeJson
        }

        let session = createURLSession()

        let (data, _) = try await session.upload(for: request, from: jsonData)
        guard let response = try? JSONDecoder().decode(GPTResponse.self, from: data),
              let responseString = response.choices.first?.message.content
        else {
            throw RequestFactoryError.failedToDecodeJson
        }
        return responseString
    }

    public static func createURLRequest(
        baseUrl: String,
        authKey: String
    ) -> URLRequest {
        var request = URLRequest(url: URL(string: baseUrl)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    private static func createURLSession() -> URLSession {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 1200
        sessionConfig.timeoutIntervalForResource = 1200
        return URLSession(configuration: sessionConfig)
    }
}
