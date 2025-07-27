//
//  NavigationEnvironmentProtocol.swift
//  Navigation
//
//  Created by iakalann on 17/07/2025.
//

import Foundation
import Audio

public protocol NavigationEnvironmentProtocol {
    @MainActor func selectChapter(storyId: UUID)
    func playSound(_ sound: AppSound)
}
