//
//  SnackBarStateTests.swift
//  SnackBar
//
//  Created by Isaac Akalanne on 22/09/2025.
//

import Testing
@testable import SnackBar

final class SnackBarStateTests {
    
    @Test
    func snackBarState_defaultInit() {
        let state = SnackBarState()
        
        #expect(state.isShowing == false)
        #expect(state.type == .none)
    }
    
    @Test
    func snackBarState_customInit() {
        let state = SnackBarState(
            isShowing: true,
            type: .moderatingText
        )
        
        #expect(state.isShowing == true)
        #expect(state.type == .moderatingText)
    }
    
    @Test
    func snackBarState_equatable() {
        let state1 = SnackBarState.arrange
        let state2 = SnackBarState.arrange
        let state3 = SnackBarState.arrange(
            isShowing: true,
            type: .moderatingText
        )
        
        #expect(state1 == state2)
        #expect(state1 != state3)
    }
}
