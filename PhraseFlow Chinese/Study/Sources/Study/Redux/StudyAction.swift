//
//  StudyAction.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import Audio
import AVKit
import Foundation
import Settings

enum StudyAction {
    case failedToPrepareStudyWord
    case playStudyWord
    case prepareToPlayStudySentence(Definition)
    case prepareToPlayStudyWord(Definition)
    case failedToPrepareStudySentence
    case onPreparedStudyWord(AVPlayer)
    case onPreparedStudySentence(AVPlayer)
    case playStudySentence
    case pauseStudyAudio
    case updateStudyAudioPlaying(Bool)
    case updateDisplayStatus(StudyDisplayStatus)
    
    case addDefinitions([Definition])
    
    case deleteDefinition(Definition)
    case failedToDeleteDefinition
    case updateStudiedWord(Definition)
    case refreshAppSettings(SettingsState)
    case playSound(AppSound)
    
    case loadDefinitions
    case onLoadDefinitions([Definition])
    case failedToLoadDefinitions
}
