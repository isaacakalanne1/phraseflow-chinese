//
//  StoryDataStoreProtocol.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Combine
import Foundation

protocol StoryDataStoreProtocol {
    var storySubject: CurrentValueSubject<Story?, Never> { get }
    func saveStory(_ story: Story) throws
    func loadAllStories() throws -> [Story]
    func unsaveStory(_ story: Story) throws

    func saveChapter(_ chapter: Chapter, storyId: UUID, chapterIndex: Int) throws
    func loadAllChapters(for storyId: UUID) throws -> [Chapter]
}
