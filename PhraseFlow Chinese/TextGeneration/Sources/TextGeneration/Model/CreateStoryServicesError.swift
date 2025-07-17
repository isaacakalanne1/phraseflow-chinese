//
//  FlowTaleServicesError.swift
//  FlowTale
//
//  Created by iakalann on 17/04/2025.
//

enum CreateStoryServicesError: Error {
    case generalError
    case invalidJSON
    case failedToGetDeviceLanguage
    case failedToGetResponseData
    case failedToEncodeJson
    case failedToDecodeJson
    case failedToDecodeSentences
    case failedToGetTimestamps
}
