//
//  NavigationMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation
import ReduxKit

let navigationMiddleware: Middleware<FlowTaleState, FlowTaleAction, FlowTaleEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .navigationAction(let navigationAction):
        switch navigationAction {
        case .selectChapter:
            return .navigationAction(.onSelectedChapter)
        case .onSelectedChapter:
            if let currentChapter = state.storyState.currentChapter {
                let existingDefinitions = state.definitionState.definitions
                var firstMissingSentenceIndex: Int?
                
                for (sentenceIndex, sentence) in currentChapter.sentences.enumerated() {
                    let sentenceHasDefinitions = sentence.timestamps.allSatisfy { timestamp in
                        existingDefinitions.contains { $0.timestampData == timestamp }
                    }
                    
                    if !sentenceHasDefinitions {
                        firstMissingSentenceIndex = sentenceIndex
                        break
                    }
                }
                
                if let sentenceIndex = firstMissingSentenceIndex {
                    return .definitionAction(.defineSentence(sentenceIndex: sentenceIndex, previousDefinitions: []))
                }
            }
            return .navigationAction(.selectTab(.reader, shouldPlaySound: false))
        case .selectTab(_, let shouldPlaySound):
            return shouldPlaySound ? .audioAction(.playSound(.tabPress)) : nil
        }
    default:
        return nil
    }
}
