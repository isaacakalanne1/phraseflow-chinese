//
//  StudyDisplayStatus.swift
//  FlowTale
//
//  Created by iakalann on 13/07/2025.
//

public enum StudyDisplayStatus: Sendable {
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
