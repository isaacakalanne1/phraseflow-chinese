//
//  SnackBarEnvironment.swift
//  SnackBar
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import Combine

public class SnackBarEnvironment: SnackBarEnvironmentProtocol {
    public let snackBarSubject = CurrentValueSubject<SnackBarType?, Never>(nil)
    
    public init() {}
    
    public func showSnackBar(_ type: SnackBarType) {
        snackBarSubject.send(type)
    }
}