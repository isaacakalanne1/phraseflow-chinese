//
//  StudyAction.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import Foundation

public enum StudyAction {
    case failedToPrepareStudyWord
    case playStudyWord(Definition)
    case prepareToPlayStudySentence(Definition)
    case failedToPrepareStudySentence
    case onPreparedStudySentence(Data)
    case playStudySentence
    case pauseStudyAudio
    case updateStudyAudioPlaying(Bool)
    case updateDisplayStatus(StudyDisplayStatus)
}
