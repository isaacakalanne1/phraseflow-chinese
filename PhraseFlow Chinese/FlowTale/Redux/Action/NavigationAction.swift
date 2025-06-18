//
//  NavigationAction.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation

enum NavigationAction {
    case selectChapter(Story, chapterIndex: Int)
    case onSelectedChapter
    case selectTab(ContentTab, shouldPlaySound: Bool)
}