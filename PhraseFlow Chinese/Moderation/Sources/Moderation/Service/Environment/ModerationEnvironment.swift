//
//  ModerationEnvironment.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation

public struct ModerationEnvironment: ModerationEnvironmentProtocol {
    private let moderationServices: ModerationServicesProtocol
    
    public init(
        moderationServices: ModerationServicesProtocol
    ) {
        self.moderationServices = moderationServices
    }
    
    public func moderateText(_ text: String) async throws -> ModerationResponse {
        return try await moderationServices.moderateText(text)
    }
}
