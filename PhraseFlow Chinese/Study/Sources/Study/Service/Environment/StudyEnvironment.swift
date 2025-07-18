//
//  StudyEnvironment.swift
//  Study
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import Definition

struct StudyEnvironment: StudyEnvironmentProtocol {
    let definitionEnvironment: DefinitionEnvironmentProtocol
    let speechPlayRate: Float
    
    func loadSentenceAudio(id: UUID) throws -> Data {
        return try definitionEnvironment.loadSentenceAudio(id: id)
    }
}