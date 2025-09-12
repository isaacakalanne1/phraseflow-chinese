//
//  CharacterUsageRecord.swift
//  FlowTale
//
//  Created by iakalann on 17/04/2025.
//

import Foundation

public struct CharacterUsageRecord: Codable {
    public let timestamp: Date
    public let characterCount: Int
    
    public init(timestamp: Date, characterCount: Int) {
        self.timestamp = timestamp
        self.characterCount = characterCount
    }
}
