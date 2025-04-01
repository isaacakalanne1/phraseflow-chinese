//
//  AppSound.swift
//  FlowTale
//
//  Created by iakalann on 04/01/2025.
//

import Foundation

enum AppSound: String {
    case actionButtonPress, changeSettings, togglePress, largeHorns, largeBoom, chunkyHit, tabPress, backButtonPress, openStory, openChapter, snackbar, errorSnackbar, progressUpdate, openStorySettings, createStory, nextStudyWord, previousStudyWord, createNextChapter, goToNextChapter

    var fileURL: URL? {
        let fileName = rawValue.prefix(1).uppercased() + rawValue.dropFirst()
        return Bundle.main.url(forResource: fileName, withExtension: "mp3")
    }
}
