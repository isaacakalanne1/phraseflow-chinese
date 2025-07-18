//
//  StudyEnvironmentProtocol.swift
//  Study
//
//  Created by iakalann on 18/07/2025.
//

import Foundation

protocol StudyEnvironmentProtocol {
    var speechPlayRate: Float { get }
    func loadSentenceAudio(id: UUID) throws -> Data
}