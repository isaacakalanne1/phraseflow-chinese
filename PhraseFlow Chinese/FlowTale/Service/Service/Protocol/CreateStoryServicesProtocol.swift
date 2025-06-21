//
//  CreateStoryServicesProtocol.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

protocol CreateStoryServicesProtocol {
    func generateChapter(previousChapters: [Chapter], deviceLanguage: Language?) async throws -> Chapter
}
