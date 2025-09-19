//
//  MockModerationEnvironment.swift
//  Moderation
//
//  Created by Isaac Akalanne on 19/09/2025.
//

import Moderation

enum MockModerationEnvironmentError: Error {
    case genericError
}

public class MockModerationEnvironment: ModerationEnvironmentProtocol {

    var moderateTextSpy: String?
    var moderateTextCalled = false
    var moderateTextResult: Result<ModerationResponse, MockModerationEnvironmentError> = .success(.arrange)
    public func moderateText(_ text: String) async throws -> ModerationResponse {
        moderateTextSpy = text
        moderateTextCalled = true
        switch moderateTextResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
}
