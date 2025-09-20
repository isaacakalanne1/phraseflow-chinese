//
//  StudyState+Arrange.swift
//  Study
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import AVKit
import Foundation
import Settings
import SettingsMocks
import Study

public extension StudyState {
    static var arrange: StudyState {
        .arrange()
    }
    
    static func arrange(
        audioPlayer: AVPlayer = AVPlayer(),
        sentenceAudioPlayer: AVPlayer = AVPlayer(),
        definitions: [Definition] = [],
        displayStatus: StudyDisplayStatus = .wordShown,
        settings: SettingsState = .arrange
    ) -> StudyState {
        .init(
            audioPlayer: audioPlayer,
            sentenceAudioPlayer: sentenceAudioPlayer,
            definitions: definitions,
            displayStatus: displayStatus,
            settings: settings
        )
    }
}
