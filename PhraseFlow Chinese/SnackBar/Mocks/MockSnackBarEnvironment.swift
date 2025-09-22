//
//  MockSnackBarEnvironment.swift
//  SnackBar
//
//  Created by Isaac Akalanne on 22/09/2025.
//

import Combine
import SnackBar

public class MockSnackBarEnvironment: SnackBarEnvironmentProtocol {
    public var snackbarStatus: CurrentValueSubject<SnackBarType, Never>
    
    var setSnackbarTypeSpy: SnackBarType?
    var setSnackbarTypeCalled = false
    
    public init() {
        snackbarStatus = .init(.none)
    }
    
    public func setSnackbarType(_ type: SnackBarType) {
        setSnackbarTypeSpy = type
        setSnackbarTypeCalled = true
        snackbarStatus.send(type)
    }
}
