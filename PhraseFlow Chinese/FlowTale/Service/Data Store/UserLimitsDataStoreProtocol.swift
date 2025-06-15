//
//  UserLimitsDataStoreProtocol.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation

protocol UserLimitsDataStoreProtocol {
    func trackSSMLCharacterUsage(characterCount: Int, subscription: SubscriptionLevel?) throws
}
