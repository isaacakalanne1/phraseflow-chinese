//
//  ModerationEnvironmentProtocol.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation

public protocol ModerationEnvironmentProtocol {
    func moderateText(_ text: String) async throws -> ModerationResponse
}
