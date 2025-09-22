//
//  SnackBarState+Arrange.swift
//  SnackBar
//
//  Created by Isaac Akalanne on 22/09/2025.
//

import SnackBar

public extension SnackBarState {
    static var arrange: SnackBarState {
        .arrange()
    }

    static func arrange(
        isShowing: Bool = false,
        type: SnackBarType = .moderatingText
    ) -> SnackBarState {
        return SnackBarState(
            isShowing: isShowing,
            type: type
        )
    }
}
