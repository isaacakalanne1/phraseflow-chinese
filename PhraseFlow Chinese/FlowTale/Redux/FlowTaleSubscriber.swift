//
//  FlowTaleSubscriber.swift
//  FlowTale
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import ReduxKit

let flowTaleSubscriber: OnSubscribe<FlowTaleStore, FlowTaleEnvironmentProtocol> = { store, environment in

    store
        .subscribe(
            environment.dataStore.storySubject
        ) { store, story in
            if let story {
                store.dispatch(.storyAction(.loadStories(isAppLaunch: false)))
            }
        }

    store
        .subscribe(
            environment.dataStore.definitionsSubject
        ) { store, definition in
            if let definition {
                store.dispatch(.definitionAction(.loadDefinitions))
            }
        }

    store
        .subscribe(
            environment.loadingSubject
        ) { store, loadingState in
            if let loadingState {
                store.dispatch(.storyAction(.updateLoadingState(loadingState)))
            }
        }

    store
        .subscribe(
            environment.storySubject
        ) { store, story in
            if let story {
                // Convert story to chapters and save them
                for chapter in story.chapters {
                    let chapterWithStoryData = Chapter(
                        id: chapter.id,
                        storyId: story.id,
                        title: chapter.title,
                        sentences: chapter.sentences,
                        audioVoice: chapter.audioVoice,
                        audio: chapter.audio,
                        passage: chapter.passage,
                        chapterSummary: story.briefLatestStorySummary,
                        difficulty: story.difficulty,
                        language: story.language,
                        storyTitle: story.title,
                        currentPlaybackTime: chapter.currentPlaybackTime,
                        lastUpdated: story.lastUpdated,
                        storyPrompt: story.storyPrompt,
                        imageData: story.imageData
                    )
                    store.dispatch(.storyAction(.saveChapter(chapterWithStoryData)))
                }
            }
        }
}
