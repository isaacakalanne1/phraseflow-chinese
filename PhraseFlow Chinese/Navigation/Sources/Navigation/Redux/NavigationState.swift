//
//  NavigationState.swift
//  Navigation
//
//  Created by iakalann on 17/07/2025.
//

struct NavigationState: Equatable {
    var contentTab: ContentTab = .reader
    var isShowingFreeLimitExplanation: Bool = false
    var isShowingDailyLimitExplanation: Bool = false
    var dailyLimitNextAvailable: String = ""
}
