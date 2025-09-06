//
//  ContentTab.swift
//  FlowTale
//
//  Created by iakalann on 17/04/2025.
//

import AppleIcon
import Foundation
import Localization
import SwiftUI

enum ContentTab: CaseIterable, Equatable, Identifiable, Hashable {
    var id: String {
        switch self {
        case .reader: return "reader"
        case .progress: return "progress"
        case .translate: return "translate"
        case .subscribe: return "subscribe"
        case .settings: return "settings"
        }
    }

    case reader, progress, translate, subscribe, settings

    var title: String {
        switch self {
        case .reader:
            "Reader" // TODO: Localize
        case .progress:
            LocalizedString.progress
        case .translate:
            LocalizedString.translate
        case .subscribe:
            LocalizedString.subscribe
        case .settings:
            LocalizedString.settings
        }
    }

    func image(isSelected: Bool) -> SystemImage {
        switch self {
        case .reader:
            .book(isSelected: isSelected)
        case .progress:
            .chartLine(isSelected: isSelected)
        case .translate:
            .translate(isSelected: isSelected)
        case .subscribe:
            .heart(isSelected: isSelected)
        case .settings:
            .gear(isSelected: isSelected)
        }
    }

}
