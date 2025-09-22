//
//  SnackBarReducerTests.swift
//  SnackBar
//
//  Created by Isaac Akalanne on 22/09/2025.
//

import Testing
@testable import SnackBar

final class SnackBarReducerTests {
    
    @Test
    func setType_updatesType() {
        let initialState = SnackBarState.arrange()
        
        let newState = snackBarReducer(initialState, .setType(.passedModeration))
        
        #expect(newState.type == .passedModeration)
        #expect(newState.isShowing == false)
    }
    
    @Test
    func showSnackbar_setsIsShowingTrue() {
        let initialState = SnackBarState.arrange(isShowing: false, type: .welcomeBack)
        
        let newState = snackBarReducer(initialState, .showSnackbar)
        
        #expect(newState.isShowing == true)
        #expect(newState.type == .welcomeBack)
    }
    
    @Test
    func hideSnackbar_setsIsShowingFalse() {
        let initialState = SnackBarState.arrange(isShowing: true, type: .subscribed)
        
        let newState = snackBarReducer(initialState, .hideSnackbar)
        
        #expect(newState.isShowing == false)
        #expect(newState.type == .subscribed)
    }
    
    @Test
    func checkDeviceVolumeZero_doesNotChangeState() {
        let initialState = SnackBarState.arrange(isShowing: true, type: .deletedCustomStory)
        
        let newState = snackBarReducer(initialState, .checkDeviceVolumeZero)
        
        #expect(newState == initialState)
    }
}
