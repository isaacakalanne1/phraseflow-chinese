//
//  ModerationDataStoreProtocol.swift
//  Moderation
//
//  Created by Isaac Akalanne on 20/07/2025.
//

import Combine
import Foundation

public protocol ModerationDataStoreProtocol {
    func saveModerationRecord(_ record: ModerationRecord) throws
    func loadModerationHistory() throws -> [ModerationRecord]
    func deleteModerationRecord(id: UUID) throws
    func cleanupOrphanedModerationFiles() throws
}