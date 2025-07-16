//
//  Gender.swift
//  FlowTale
//
//  Created by iakalann on 04/11/2024.
//

import Foundation

enum Gender: String {
    case male, female

    var title: String {
        switch self {
        case .male:
            LocalizedString.male
        case .female:
            LocalizedString.female
        }
    }
}
