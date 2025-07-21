//
//  ModerationRecord.swift
//  Moderation
//
//  Created by Isaac Akalanne on 20/07/2025.
//

import Foundation

struct ModerationRecord: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let prompt: String
    let moderationResponse: ModerationResponse
    let didPass: Bool
    
    init(prompt: String, moderationResponse: ModerationResponse) {
        self.id = UUID()
        self.timestamp = Date()
        self.prompt = prompt
        self.moderationResponse = moderationResponse
        self.didPass = moderationResponse.didPassModeration
    }
}