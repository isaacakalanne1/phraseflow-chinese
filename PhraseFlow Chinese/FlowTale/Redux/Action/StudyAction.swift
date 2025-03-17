//
//  StudyAction.swift
//  FlowTale
//
//  Created by iakalann on 22/03/2025.
//

enum StudyAction {
    case updateStudyChapter(Chapter?)

    case prepareToPlayStudyWord(WordTimeStampData, Sentence)
    case failedToPrepareStudyWord

    case playStudyWord(WordTimeStampData)
    case playStudySentence(startWord: WordTimeStampData, endWord: WordTimeStampData)

    case pauseStudyAudio
    case updateStudyAudioPlaying(Bool)
}
