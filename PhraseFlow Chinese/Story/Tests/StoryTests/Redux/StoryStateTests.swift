//
//  StoryStateTests.swift
//  Story
//
//  Created by Isaac Akalanne on 21/09/2025.
//

import Testing
import Foundation
import Settings
import SettingsMocks
import TextGeneration
import TextGenerationMocks
import Loading
@testable import Story
@testable import StoryMocks

class StoryStateTests {
    
    @Test
    func initializer_setsDefaultValues() {
        let storyState = StoryState()
        
        #expect(storyState.currentChapter == nil)
        #expect(storyState.storyChapters.isEmpty)
        #expect(storyState.isWritingChapter == false)
        #expect(storyState.isPlayingChapterAudio == false)
        #expect(storyState.viewState == StoryViewState())
        #expect(storyState.settings == SettingsState())
    }
    
    @Test
    func initializer_withCustomValues() {
        let chapter = Chapter.arrange
        let storyId = UUID()
        let chapters = [Chapter.arrange, Chapter.arrange]
        let storyChapters = [storyId: chapters]
        let viewState = StoryViewState(loadingState: .writing, isDefining: true)
        let settings = SettingsState.arrange(language: .mandarinChinese)
        
        let storyState = StoryState(
            currentChapter: chapter,
            storyChapters: storyChapters,
            isWritingChapter: true,
            viewState: viewState,
            isPlayingChapterAudio: true,
            settings: settings
        )
        
        #expect(storyState.currentChapter == chapter)
        #expect(storyState.storyChapters == storyChapters)
        #expect(storyState.isWritingChapter == true)
        #expect(storyState.isPlayingChapterAudio == true)
        #expect(storyState.viewState == viewState)
        #expect(storyState.settings == settings)
    }
    
    @Test
    func allStories_emptyStoryChapters_returnsEmptyArray() {
        let storyState = StoryState.arrange(storyChapters: [:])
        
        #expect(storyState.allStories.isEmpty)
    }
    
    @Test
    func allStories_singleStory_returnsSingleStory() {
        let storyId = UUID()
        let chapters = [Chapter.arrange]
        let storyChapters = [storyId: chapters]
        let storyState = StoryState.arrange(storyChapters: storyChapters)
        
        let allStories = storyState.allStories
        
        #expect(allStories.count == 1)
        #expect(allStories[0].storyId == storyId)
        #expect(allStories[0].chapters == chapters)
    }
    
    @Test
    func allStories_multipleStories_sortsByLatestUpdate() {
        let storyId1 = UUID()
        let storyId2 = UUID()
        let storyId3 = UUID()
        
        let oldDate = Date().addingTimeInterval(-100)
        let recentDate = Date().addingTimeInterval(-50)
        let latestDate = Date()
        
        let oldChapter = Chapter.arrange(lastUpdated: oldDate)
        let recentChapter = Chapter.arrange(lastUpdated: recentDate)
        let latestChapter = Chapter.arrange(lastUpdated: latestDate)
        
        let storyChapters = [
            storyId1: [oldChapter],
            storyId2: [recentChapter],
            storyId3: [latestChapter]
        ]
        
        let storyState = StoryState.arrange(storyChapters: storyChapters)
        let allStories = storyState.allStories
        
        #expect(allStories.count == 3)
        #expect(allStories[0].storyId == storyId3)
        #expect(allStories[1].storyId == storyId2)
        #expect(allStories[2].storyId == storyId1)
    }
    
    @Test
    func allStories_multipleChaptersPerStory_sortsByLatestChapterInEachStory() {
        let storyId1 = UUID()
        let storyId2 = UUID()
        
        let oldDate = Date().addingTimeInterval(-100)
        let recentDate = Date().addingTimeInterval(-50)
        let latestDate = Date()
        
        let story1OldChapter = Chapter.arrange(lastUpdated: oldDate)
        let story1LatestChapter = Chapter.arrange(lastUpdated: latestDate)
        
        let story2RecentChapter = Chapter.arrange(lastUpdated: recentDate)
        let story2OldChapter = Chapter.arrange(lastUpdated: oldDate)
        
        let storyChapters = [
            storyId1: [story1OldChapter, story1LatestChapter],
            storyId2: [story2RecentChapter, story2OldChapter]
        ]
        
        let storyState = StoryState.arrange(storyChapters: storyChapters)
        let allStories = storyState.allStories
        
        #expect(allStories.count == 2)
        #expect(allStories[0].storyId == storyId1)
        #expect(allStories[1].storyId == storyId2)
    }
    
    @Test
    func firstChapter_storyDoesNotExist_returnsNil() {
        let storyState = StoryState.arrange(storyChapters: [:])
        let nonExistentStoryId = UUID()
        
        let firstChapter = storyState.firstChapter(for: nonExistentStoryId)
        
        #expect(firstChapter == nil)
    }
    
    @Test
    func firstChapter_storyExists_returnsEarliestChapter() {
        let storyId = UUID()
        let oldDate = Date().addingTimeInterval(-100)
        let recentDate = Date().addingTimeInterval(-50)
        let latestDate = Date()
        
        let oldestChapter = Chapter.arrange(lastUpdated: oldDate)
        let recentChapter = Chapter.arrange(lastUpdated: recentDate)
        let latestChapter = Chapter.arrange(lastUpdated: latestDate)
        
        let chapters = [recentChapter, latestChapter, oldestChapter]
        let storyChapters = [storyId: chapters]
        let storyState = StoryState.arrange(storyChapters: storyChapters)
        
        let firstChapter = storyState.firstChapter(for: storyId)
        
        #expect(firstChapter == oldestChapter)
    }
    
    @Test
    func firstChapter_singleChapter_returnsThatChapter() {
        let storyId = UUID()
        let chapter = Chapter.arrange
        let storyChapters = [storyId: [chapter]]
        let storyState = StoryState.arrange(storyChapters: storyChapters)
        
        let firstChapter = storyState.firstChapter(for: storyId)
        
        #expect(firstChapter == chapter)
    }
    
    @Test
    func isLastChapter_noCurrentChapter_returnsFalse() {
        let storyState = StoryState.arrange(currentChapter: nil)
        
        #expect(storyState.isLastChapter == false)
    }
    
    @Test
    func isLastChapter_currentChapterStoryNotFound_returnsFalse() {
        let currentChapter = Chapter.arrange
        let storyState = StoryState.arrange(
            currentChapter: currentChapter,
            storyChapters: [:]
        )
        
        #expect(storyState.isLastChapter == false)
    }
    
    @Test
    func isLastChapter_currentChapterNotInChaptersList_returnsFalse() {
        let currentChapter = Chapter.arrange
        let otherChapter = Chapter.arrange
        let storyChapters = [currentChapter.storyId: [otherChapter]]
        let storyState = StoryState.arrange(
            currentChapter: currentChapter,
            storyChapters: storyChapters
        )
        
        #expect(storyState.isLastChapter == false)
    }
    
    @Test
    func isLastChapter_firstChapterOfMultiple_returnsFalse() {
        let storyId = UUID()
        let chapter1 = Chapter.arrange(storyId: storyId)
        let chapter2 = Chapter.arrange(storyId: storyId)
        let chapter3 = Chapter.arrange(storyId: storyId)
        let chapters = [chapter1, chapter2, chapter3]
        let storyChapters = [storyId: chapters]
        let storyState = StoryState.arrange(
            currentChapter: chapter1,
            storyChapters: storyChapters
        )
        
        #expect(storyState.isLastChapter == false)
    }
    
    @Test
    func isLastChapter_middleChapterOfMultiple_returnsFalse() {
        let storyId = UUID()
        let chapter1 = Chapter.arrange(storyId: storyId)
        let chapter2 = Chapter.arrange(storyId: storyId)
        let chapter3 = Chapter.arrange(storyId: storyId)
        let chapters = [chapter1, chapter2, chapter3]
        let storyChapters = [storyId: chapters]
        let storyState = StoryState.arrange(
            currentChapter: chapter2,
            storyChapters: storyChapters
        )
        
        #expect(storyState.isLastChapter == false)
    }
    
    @Test
    func isLastChapter_lastChapterOfMultiple_returnsTrue() {
        let storyId = UUID()
        let chapter1 = Chapter.arrange(storyId: storyId)
        let chapter2 = Chapter.arrange(storyId: storyId)
        let chapter3 = Chapter.arrange(storyId: storyId)
        let chapters = [chapter1, chapter2, chapter3]
        let storyChapters = [storyId: chapters]
        let storyState = StoryState.arrange(
            currentChapter: chapter3,
            storyChapters: storyChapters
        )
        
        #expect(storyState.isLastChapter == true)
    }
    
    @Test
    func isLastChapter_singleChapter_returnsTrue() {
        let storyId = UUID()
        let chapter = Chapter.arrange(storyId: storyId)
        let storyChapters = [storyId: [chapter]]
        let storyState = StoryState.arrange(
            currentChapter: chapter,
            storyChapters: storyChapters
        )
        
        #expect(storyState.isLastChapter == true)
    }
    
    @Test
    func equatable_sameStates() {
        let chapter = Chapter.arrange
        let storyChapters = [UUID(): [chapter]]
        let viewState = StoryViewState(isDefining: true)
        let settings = SettingsState.arrange(language: .english)
        
        let state1 = StoryState.arrange(
            currentChapter: chapter,
            storyChapters: storyChapters,
            isWritingChapter: true,
            viewState: viewState,
            settings: settings
        )
        
        let state2 = StoryState.arrange(
            currentChapter: chapter,
            storyChapters: storyChapters,
            isWritingChapter: true,
            viewState: viewState,
            settings: settings
        )
        
        #expect(state1 == state2)
    }
    
    @Test
    func equatable_differentCurrentChapter() {
        let chapter1 = Chapter.arrange
        let chapter2 = Chapter.arrange
        
        let state1 = StoryState.arrange(currentChapter: chapter1)
        let state2 = StoryState.arrange(currentChapter: chapter2)
        
        #expect(state1 != state2)
    }
    
    @Test
    func equatable_differentStoryChapters() {
        let storyChapters1 = [UUID(): [Chapter.arrange]]
        let storyChapters2 = [UUID(): [Chapter.arrange, Chapter.arrange]]
        
        let state1 = StoryState.arrange(storyChapters: storyChapters1)
        let state2 = StoryState.arrange(storyChapters: storyChapters2)
        
        #expect(state1 != state2)
    }
    
    @Test
    func equatable_differentIsWritingChapter() {
        let state1 = StoryState.arrange(isWritingChapter: true)
        let state2 = StoryState.arrange(isWritingChapter: false)
        
        #expect(state1 != state2)
    }
    
    @Test
    func equatable_differentViewState() {
        let viewState1 = StoryViewState(loadingState: .writing)
        let viewState2 = StoryViewState(loadingState: .complete)
        
        let state1 = StoryState.arrange(viewState: viewState1)
        let state2 = StoryState.arrange(viewState: viewState2)
        
        #expect(state1 != state2)
    }
    
    @Test
    func equatable_differentIsPlayingChapterAudio() {
        let state1 = StoryState.arrange(isPlayingChapterAudio: true)
        let state2 = StoryState.arrange(isPlayingChapterAudio: false)
        
        #expect(state1 != state2)
    }
    
    @Test
    func equatable_differentSettings() {
        let settings1 = SettingsState.arrange(language: .english)
        let settings2 = SettingsState.arrange(language: .spanish)
        
        let state1 = StoryState.arrange(settings: settings1)
        let state2 = StoryState.arrange(settings: settings2)
        
        #expect(state1 != state2)
    }
}

