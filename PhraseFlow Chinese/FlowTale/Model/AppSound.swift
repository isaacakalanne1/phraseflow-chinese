//
//  AppSound.swift
//  FlowTale
//
//  Created by iakalann on 04/01/2025.
//

import Foundation

enum AppSound {
    case mainActionButtonPress, changeSettings

    var fileURL: URL? {
        let fileName: String
        switch self {
        case .mainActionButtonPress:
            fileName = "ActionButtonViewPress"
        case .changeSettings:
            fileName = "ChangeSettings"
        }
        return Bundle.main.url(forResource: fileName, withExtension: "mp3")
    }
}
