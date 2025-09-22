//
//  SnackBarMiddlewareTests.swift
//  SnackBar
//
//  Created by Isaac Akalanne on 22/09/2025.
//

import Testing
@testable import SnackBar
@testable import SnackBarMocks

final class SnackBarMiddlewareTests {
    let mockEnvironment = MockSnackBarEnvironment()
    
    @Test
    func setType_withNone_returnsHideSnackbar() async {
        let state = SnackBarState.arrange(isShowing: false, type: .none)
        
        let action = await snackBarMiddleware(state, .setType(.none), mockEnvironment)
        
        #expect(action == .hideSnackbar)
    }
    
    @Test
    func setType_withValidType_returnsShowSnackbar() async {
        let state = SnackBarState.arrange(isShowing: false, type: .welcomeBack)
        
        let action = await snackBarMiddleware(state, .setType(.welcomeBack), mockEnvironment)
        
        #expect(action == .showSnackbar)
    }
    
    @Test
    func showSnackbar_withDuration_returnsHideSnackbarAfterDelay() async {
        let state = SnackBarState.arrange(isShowing: false, type: .deviceVolumeZero)
        
        let action = await snackBarMiddleware(state, .showSnackbar, mockEnvironment)
        
        #expect(action == .hideSnackbar)
    }
    
    @Test
    func showSnackbar_withDuration_returnsHideSnackbarAfterDelay_defaultDuration() async {
        let state = SnackBarState.arrange(isShowing: false, type: .moderatingText)
        
        let action = await snackBarMiddleware(state, .showSnackbar, mockEnvironment)
        
        #expect(action == .hideSnackbar)
    }
    
    @Test
    func hideSnackbar_returnsNil() async {
        let state = SnackBarState.arrange(isShowing: true, type: .subscribed)
        
        let action = await snackBarMiddleware(state, .hideSnackbar, mockEnvironment)
        
        #expect(action == nil)
    }
}
