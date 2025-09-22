//
//  SnackBarEnvironment.swift
//  SnackBar
//
//  Created by iakalann on 18/07/2025.
//

import Combine

public class SnackBarEnvironment: SnackBarEnvironmentProtocol {
    
    public var snackbarStatus: CurrentValueSubject<SnackBarType, Never>
    
    public init() {
        snackbarStatus = .init(.none)
    }
    
    public func setSnackbarType(_ type: SnackBarType) {
        snackbarStatus.send(type)
    }
}
