//
//  MockModerationServices.swift
//  Moderation
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Moderation

enum MockModerationServicesError: Error {
    case genericError
}

public class MockModerationServices: ModerationServicesProtocol {
    
    var moderateTextSpy: String?
    var moderateTextCalled = false
    var moderateTextResult: Result<ModerationResponse, MockModerationServicesError> = .success(.arrange)
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
