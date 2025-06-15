//
//  CreateStoryServicesProtocol.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

protocol CreateStoryServicesProtocol {
    func generateStory(story: Story, deviceLanguage: Language?) async throws -> Story
}
