//
//  StoryEnvironment.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import Combine

public struct StoryEnvironment: StoryEnvironmentProtocol {
    public let storySubject = CurrentValueSubject<UUID?, Never>(nil)
    
    public init() {}
    
    public func selectChapter(storyId: UUID) {
        storySubject.send(storyId)
    }
}