//
//  StudyDisplayStatus.swift
//  FlowTale
//
//  Created by iakalann on 13/07/2025.
//

enum StudyDisplayStatus {
    case wordShown
    case pronounciationShown
    case allShown

    var nextStatus: StudyDisplayStatus {
        switch self {
        case .wordShown:
                .pronounciationShown
        case .pronounciationShown:
                .allShown
        case .allShown:
                .wordShown
        }
    }
}
