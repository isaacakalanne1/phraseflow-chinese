//
//  SnackBarEnvironmentTests.swift
//  SnackBar
//
//  Created by Isaac Akalanne on 22/09/2025.
//

import Testing
import Combine
@testable import SnackBar

final class SnackBarEnvironmentTests {
    
    @Test
    func init_startsWithNone() {
        let environment = SnackBarEnvironment()
        
        #expect(environment.snackbarStatus.value == .none)
    }
    
    @Test
    func setSnackbarType_updatesSubject() {
        let environment = SnackBarEnvironment()
        
        environment.setSnackbarType(.moderatingText)
        
        #expect(environment.snackbarStatus.value == .moderatingText)
    }
    
    @Test
    func setSnackbarType_propagatesToSubscribers() {
        let environment = SnackBarEnvironment()
        var receivedTypes: [SnackBarType] = []
        
        let cancellable = environment.snackbarStatus
            .sink { type in
                receivedTypes.append(type)
            }
        
        environment.setSnackbarType(.moderatingText)
        environment.setSnackbarType(.deletedCustomStory)
        environment.setSnackbarType(.none)
        
        #expect(receivedTypes == [.none, .moderatingText, .deletedCustomStory, .none])
        
        cancellable.cancel()
    }
}
