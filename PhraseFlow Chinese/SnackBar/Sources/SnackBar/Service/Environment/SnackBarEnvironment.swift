//
//  SnackBarEnvironment.swift
//  SnackBar
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import Combine

class SnackBarEnvironment: SnackBarEnvironmentProtocol {
    let snackBarSubject = CurrentValueSubject<SnackBarType?, Never>(nil)
    
    func showSnackBar(_ type: SnackBarType) {
        snackBarSubject.send(type)
    }
}