//
//  StoryMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import AVKit
import Foundation
import ReduxKit

let storyMiddleware: Middleware<FlowTaleState, FlowTaleAction, FlowTaleEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .storyAction(let storyAction):
        switch storyAction {
        case .createChapter(let type):
            do {
                var chapter: Chapter
                if case .existingStory(let storyId) = type {
                    chapter = state.createNewChapter(storyId: storyId)
                } else {
                    chapter = state.createNewChapter()
                }
                
                // Generate story content using existing story structure for compatibility
                var tempStory = Story(
                    difficulty: chapter.difficulty,
                    language: chapter.language,
                    storyPrompt: chapter.storyPrompt
                )
                
                tempStory = try await environment.generateStory(story: tempStory,
                                                               voice: state.settingsState.voice,
                                                               deviceLanguage: state.deviceLanguage,
                                                               currentSubscription: state.subscriptionState.currentSubscription)
                
                // Transfer generated content to chapter
                if let generatedChapter = tempStory.chapters.first {
                    chapter.title = generatedChapter.title
                    chapter.sentences = generatedChapter.sentences
                    chapter.audio = generatedChapter.audio
                    chapter.passage = generatedChapter.passage
                    chapter.audioVoice = generatedChapter.audioVoice
                }
                chapter.chapterSummary = tempStory.briefLatestStorySummary
                chapter.storyTitle = tempStory.title
                chapter.imageData = tempStory.imageData
                chapter.lastUpdated = tempStory.lastUpdated
                
                return .storyAction(.onCreatedChapter(chapter))
            } catch FlowTaleDataStoreError.freeUserCharacterLimitReached {
                return nil
            } catch FlowTaleDataStoreError.characterLimitReached(let nextAvailable) {
                return nil
            } catch {
                return nil
            }

        case .loadChapters(let storyId, let isAppLaunch):
            do {
                // Load chapters for a specific story
                let chapters = try environment.loadAllChapters(for: storyId)
                return .storyAction(.onLoadedChapters(chapters, isAppLaunch: isAppLaunch))
            } catch {
                return .storyAction(.failedToLoadChapters)
            }
        
        case .loadStories(let isAppLaunch):
            do {
                // Load all stories and convert them to chapters
                let stories = try environment.loadAllStories()
                var chapters: [Chapter] = []
                
                for story in stories {
                    let storyChapters = try environment.loadAllChapters(for: story.id)
                    
                    // Convert story chapters to new chapter format if needed
                    for (index, storyChapter) in storyChapters.enumerated() {
                        var chapter = Chapter(
                            storyId: story.id,
                            title: storyChapter.title,
                            sentences: storyChapter.sentences,
                            audioVoice: storyChapter.audioVoice,
                            audio: storyChapter.audio,
                            passage: storyChapter.passage,
                            chapterSummary: story.briefLatestStorySummary,
                            difficulty: story.difficulty,
                            language: story.language,
                            storyTitle: story.title,
                            currentPlaybackTime: index == story.currentChapterIndex ? story.currentPlaybackTime : 0,
                            lastUpdated: story.lastUpdated,
                            storyPrompt: story.storyPrompt,
                            imageData: story.imageData
                        )
                        chapters.append(chapter)
                    }
                }
                
                return .storyAction(.onLoadedChapters(chapters, isAppLaunch: isAppLaunch))
            } catch {
                return .storyAction(.failedToLoadChapters)
            }

        case .deleteStory(let storyId):
            do {
                // Create a temp story object for deletion - this is a compatibility layer
                // TODO: Update environment to work directly with storyId
                if let firstChapter = state.storyState.storyChapters[storyId]?.first {
                    let tempStory = Story(
                        briefLatestStorySummary: firstChapter.chapterSummary,
                        difficulty: firstChapter.difficulty,
                        language: firstChapter.language,
                        title: firstChapter.storyTitle,
                        storyPrompt: firstChapter.storyPrompt,
                        imageData: firstChapter.imageData
                    )
                    try environment.unsaveStory(tempStory)
                }
                return .storyAction(.onDeletedStory(storyId))
            } catch {
                return .storyAction(.failedToDeleteStory)
            }
            
        case .deleteChapter(let chapterId):
            // TODO: Implement chapter deletion in environment
            return .storyAction(.onDeletedChapter(chapterId))

        case .saveChapter(let chapter):
            do {
                // Create a temp story object for saving - this is a compatibility layer
                // TODO: Update environment to work directly with chapters
                let tempStory = Story(
                    briefLatestStorySummary: chapter.chapterSummary,
                    difficulty: chapter.difficulty,
                    language: chapter.language,
                    title: chapter.storyTitle,
                    chapters: [Chapter(storyId: chapter.storyId,
                                     title: chapter.title,
                                     sentences: chapter.sentences,
                                     audioVoice: chapter.audioVoice,
                                     audio: chapter.audio,
                                     passage: chapter.passage,
                                     language: chapter.language)],
                    storyPrompt: chapter.storyPrompt,
                    imageData: chapter.imageData,
                    lastUpdated: chapter.lastUpdated
                )
                try environment.saveStory(tempStory)
                try environment.saveAppSettings(state.settingsState)
                return .storyAction(.onSavedChapter(chapter))
            } catch {
                return .storyAction(.failedToSaveChapter)
            }

        case .goToNextChapter:
            if let currentChapter = state.storyState.currentChapter {
                return .storyAction(.saveChapter(currentChapter))
            }
            return nil
            
        case .goToPreviousChapter:
            if let currentChapter = state.storyState.currentChapter {
                return .storyAction(.saveChapter(currentChapter))
            }
            return nil
            
        case .goToChapter:
            if let currentChapter = state.storyState.currentChapter {
                return .storyAction(.saveChapter(currentChapter))
            }
            return nil

        case .onFinishedLoadedChapters:
            return nil

        case .onDeletedStory:
            return .storyAction(.loadStories(isAppLaunch: false))

        case .onLoadedChapters(let chapters, let isAppLaunch):
            return .storyAction(.onFinishedLoadedChapters)

        case .failedToCreateChapter:
            return .snackbarAction(.showSnackBar(.failedToWriteChapter))
        case .failedToLoadChapters,
                .failedToDeleteStory,
                .failedToDeleteChapter,
                .failedToSaveChapter,
                .updateAutoScrollEnabled,
                .updateCurrentSentence,
                .updatePlaybackTime,
                .onCreatedChapter,
                .onDeletedChapter,
                .onSavedChapter,
                .setCurrentStory,
                .updateLoadingState:
            return nil
        }
    default:
        return nil
    }
}
