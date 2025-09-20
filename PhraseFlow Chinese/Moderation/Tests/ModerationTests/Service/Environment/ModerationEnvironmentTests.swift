//
//  ModerationEnvironmentTests.swift
//  Moderation
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Testing
@testable import Moderation
@testable import ModerationMocks

class ModerationEnvironmentTests {
    let mockModerationServices: MockModerationServices
    let environment: ModerationEnvironment
    
    init() {
        self.mockModerationServices = MockModerationServices()
        self.environment = ModerationEnvironment(
            moderationServices: mockModerationServices
        )
    }
    
    @Test
    func moderateText_success() async throws {
        let text = "A fun story"

        let response = try await environment.moderateText(text)

        #expect(mockModerationServices.moderateTextCalled == true)
        #expect(mockModerationServices.moderateTextSpy == text)
        #expect(response == .arrange)
    }
    
    @Test
    func moderateText_error() async throws {
        let text = "A fun story"

        mockModerationServices.moderateTextResult = .failure(.genericError)
        do {
            let _ = try await environment.moderateText(text)
            Issue.record("Should have thrown an error")
        } catch {
            #expect(mockModerationServices.moderateTextCalled == true)
            #expect(mockModerationServices.moderateTextSpy == text)
        }
    }
}
