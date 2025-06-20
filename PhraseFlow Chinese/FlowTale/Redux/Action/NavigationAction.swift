//
//  NavigationAction.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation

enum NavigationAction {
    case selectChapter(UUID, chapterIndex: Int)
    case selectChapterLegacy(Story, chapterIndex: Int)
    case onSelectedChapter
    case selectTab(ContentTab, shouldPlaySound: Bool)
}