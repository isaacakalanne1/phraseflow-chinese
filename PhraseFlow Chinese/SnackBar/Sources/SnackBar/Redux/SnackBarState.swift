//
//  SnackBarState.swift
//  FlowTale
//
//  Created by iakalann on 27/12/2024.
//

import Foundation

public struct SnackBarState: Equatable {
    public var isShowing: Bool
    public var type: SnackBarType
    
    public init(
        isShowing: Bool = false,
        type: SnackBarType = .none
    ) {
        self.isShowing = isShowing
        self.type = type
    }
}
