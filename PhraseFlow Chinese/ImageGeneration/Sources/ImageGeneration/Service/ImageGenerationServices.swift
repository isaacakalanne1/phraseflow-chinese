//
//  ImageGenerationServices.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation

enum ImageGenerationServicesError: Error {
    case missingRequestID
    case missingImageURL
}

public class ImageGenerationServices: ImageGenerationServicesProtocol {
    private let baseURL = "https://queue.fal.run/fal-ai/flux"
    private let apiKey = "e1f58875-fe36-4a31-ad34-badb6bbd0409:4645ce9820c0b75b3cbe1b0d9c324306" // TODO: Store remotely and download via API
    private let session = URLSession.shared
    
    public init() { }

    public func generateImage(with prompt: String) async throws -> Data {
        let requestID = try await submitGenerationRequest(prompt: prompt)

        try await pollRequestStatus(requestID: requestID)

        let imageURL = try await fetchResult(requestID: requestID)

        let (data, _) = try await session.data(from: imageURL)

        return data
    }

    private func submitGenerationRequest(prompt: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/schnell") else {
            throw ImageGenerationServicesError.missingImageURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Key \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "prompt": "Cover art for the following story:\n\(prompt)",
            "image_size": [
                "width": 1024,
                "height": 512,
            ],
        ]

        let uploadData = try JSONSerialization.data(withJSONObject: payload)

        let (responseData, _) = try await session.upload(for: request, from: uploadData)
        let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any]

        guard let requestID = json?["request_id"] as? String else {
            throw ImageGenerationServicesError.missingRequestID
        }

        return requestID
    }

    private func pollRequestStatus(requestID: String) async throws {
        while true {
            try await Task.sleep(nanoseconds: 1_000_000_000)

            guard let url = URL(string: "\(baseURL)/requests/\(requestID)/status") else {
                fatalError("Invalid status URL")
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Key \(apiKey)", forHTTPHeaderField: "Authorization")

            let (data, _) = try await session.data(for: request)
            let statusJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

            if let status = statusJSON?["status"] as? String,
               status == "COMPLETED"
            {
                return
            }
        }
    }

    private func fetchResult(requestID: String) async throws -> URL {
        guard let url = URL(string: "\(baseURL)/requests/\(requestID)") else {
            throw ImageGenerationServicesError.missingImageURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Key \(apiKey)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await session.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

        guard
            let images = json?["images"] as? [[String: Any]],
            let urlString = images.first?["url"] as? String,
            let imageURL = URL(string: urlString)
        else {
            throw ImageGenerationServicesError.missingImageURL
        }

        return imageURL
    }
}
