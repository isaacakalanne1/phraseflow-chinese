//
//  StoryEnvironmentProtocol.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import Combine

protocol StoryEnvironmentProtocol {
    var storySubject: CurrentValueSubject<UUID?, Never> { get }
    func selectChapter(storyId: UUID)
}