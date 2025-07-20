//
//  SnackBarState.swift
//  FlowTale
//
//  Created by iakalann on 27/12/2024.
//

import Foundation

public struct SnackBarState {
    public var isShowing = false
    public var type: SnackBarType = .chapterReady
    
    public init() {}
}
