//
//  ModerationRecord.swift
//  Moderation
//
//  Created by Isaac Akalanne on 20/07/2025.
//

import Foundation

public struct ModerationRecord: Codable, Identifiable, Equatable {
    public let id: UUID
    let timestamp: Date
}
