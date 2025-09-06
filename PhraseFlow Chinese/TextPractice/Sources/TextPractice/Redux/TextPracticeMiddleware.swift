//
//  TextPracticeMiddleware.swift
//  TextPractice
//
//  Created by Isaac Akalanne on 02/09/2025.
//

import ReduxKit

nonisolated(unsafe) let textPracticeMiddleware: Middleware<TextPracticeState, TextPracticeAction, any TextPracticeEnvironmentProtocol> = { state, action, environment in
    switch action {
        
    case .goToNextChapter:
        environment.goToNextChapter()
        return nil
    case .prepareToPlayChapter(let chapter):
        await environment.prepareToPlayChapter(chapter)
        return nil
    case .playChapter(let word):
        await environment.playChapter(from: word)
        environment.setMusicVolume(.quiet)
        return nil
    case .pauseChapter:
        environment.pauseChapter()
        environment.setMusicVolume(.normal)
        return nil
    case .saveAppSettings(let settings):
        try? environment.saveAppSettings(settings)
        return nil
    case .setChapter,
            .addDefinitions,
            .setPlaybackTime,
            .updateCurrentSentence,
            .refreshSettings:
        return nil
    }
}
