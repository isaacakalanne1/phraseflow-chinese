//
//  ModerationEnvironment.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation

public struct ModerationEnvironment: ModerationEnvironmentProtocol {
    let moderationServices: ModerationServicesProtocol
    public let moderationDataStore: ModerationDataStoreProtocol
    
    public init(moderationServices: ModerationServicesProtocol,
         moderationDataStore: ModerationDataStoreProtocol) {
        self.moderationServices = moderationServices
        self.moderationDataStore = moderationDataStore
    }
    
    public func moderateText(_ text: String) async throws -> ModerationResponse {
        return try await moderationServices.moderateText(text)
    }
}
