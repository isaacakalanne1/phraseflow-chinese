//
//  ModerationServicesProtocol.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

public protocol ModerationServicesProtocol {
    func moderateText(_ text: String) async throws -> ModerationResponse
}
