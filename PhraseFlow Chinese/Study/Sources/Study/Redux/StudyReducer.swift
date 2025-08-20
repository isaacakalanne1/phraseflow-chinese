//
//  StudyReducer.swift
//  FlowTale
//
//  Created by iakalann on 06/04/2025.
//

import Audio
import AVKit
import ReduxKit

@MainActor
let studyReducer: Reducer<StudyState, StudyAction> = { state, action in
    var newState = state

    switch action {
    case .onPreparedStudySentence(let player):
        newState.sentenceAudioPlayer = player
    case .onPreparedStudyWord(let player):
        newState.audioPlayer = player
    case .failedToPrepareStudySentence:
        newState.sentenceAudioPlayer = AVPlayer()
    case .updateStudyAudioPlaying(let isPlaying):
        newState.isAudioPlaying = isPlaying
    case let .updateDisplayStatus(displayStatus):
        newState.displayStatus = displayStatus
    case .onLoadAppSettings(let settings):
        newState.filterLanguage = settings.language
        
    case .deleteDefinition(let definition):
        newState.definitions.removeAll(where: { $0.id == definition.id })
        
    case .updateStudiedWord(var definition):
        definition.studiedDates.append(.now)

        if let index = newState.definitions.firstIndex(where: { $0.timestampData == definition.timestampData }) {
            newState.definitions.replaceSubrange(index...index, with: [definition])
        } else {
            newState.definitions.append(definition)
        }
        
    case .onLoadDefinitions(let definitions):
        newState.definitions = definitions
        
    case .failedToPrepareStudyWord,
            .prepareToPlayStudySentence,
            .playStudySentence,
            .pauseStudyAudio,
            .prepareToPlayStudyWord,
            .playStudyWord,
            .failedToDeleteDefinition,
            .playSound,
            .loadDefinitions,
            .failedToLoadDefinitions:
        break
    }

    return newState
}
