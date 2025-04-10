//
//  FlowTaleDataStoreError.swift
//  FlowTale
//
//  Created by iakalann on 17/04/2025.
//

enum FlowTaleDataStoreError: Error {
    case failedToCreateUrl
    case failedToSaveData
    case failedToDecodeData
    case freeUserCharacterLimitReached
    case characterLimitReached(timeUntilNextAvailable: String)
}
