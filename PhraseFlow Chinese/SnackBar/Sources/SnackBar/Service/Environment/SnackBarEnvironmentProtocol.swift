//
//  SnackBarEnvironmentProtocol.swift
//  SnackBar
//
//  Created by iakalann on 18/07/2025.
//

import Combine

public protocol SnackBarEnvironmentProtocol {
    var snackbarStatus: CurrentValueSubject<SnackBarType, Never> { get }
    
    func setSnackbarType(_ type: SnackBarType)
}
