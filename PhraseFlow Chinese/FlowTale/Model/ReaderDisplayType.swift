//
//  ReaderDisplayType.swift
//  FlowTale
//
//  Created by iakalann on 19/10/2024.
//

import Foundation

enum ReaderDisplayType: Equatable {
    case normal
    case loading(LoadingState)
    case initialising
}
