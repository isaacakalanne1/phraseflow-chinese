//
//  StoryDataStoreProtocol.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Combine
import Foundation
import TextGeneration

protocol StoryDataStoreProtocol {
    func saveChapter(_ chapter: Chapter) throws
    func loadAllChapters() throws -> [Chapter]
    func deleteChapter(_ chapter: Chapter) throws
    func loadAllChapters(for storyId: UUID) throws -> [Chapter]
}
