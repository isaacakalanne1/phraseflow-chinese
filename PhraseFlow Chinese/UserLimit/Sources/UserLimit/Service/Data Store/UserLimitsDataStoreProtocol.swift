//
//  UserLimitsDataStoreProtocol.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation

public protocol UserLimitsDataStoreProtocol {
    func trackSSMLCharacterUsage(characterCount: Int, characterLimitPerDay: Int?) throws
}
