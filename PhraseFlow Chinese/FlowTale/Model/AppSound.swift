//
//  AppSound.swift
//  FlowTale
//
//  Created by iakalann on 04/01/2025.
//

import Foundation

enum AppSound {
    case mainActionButtonPress, changeSettings, togglePress, backButtonPress, openStory, openChapter

    var fileURL: URL? {
        let fileName: String
        switch self {
        case .mainActionButtonPress:
            fileName = "ActionButtonPress"
        case .changeSettings:
            fileName = "ChangeSettings"
        case .togglePress:
            fileName = "TogglePress"
        case .backButtonPress:
            fileName = "BackButtonPress"
        case .openStory:
            fileName = "OpenStory"
        case .openChapter:
            fileName = "OpenChapter"
        }
        return Bundle.main.url(forResource: fileName, withExtension: "mp3")
    }
}
