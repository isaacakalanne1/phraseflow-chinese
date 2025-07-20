//
//  SnackBarEnvironmentProtocol.swift
//  SnackBar
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import Combine

public protocol SnackBarEnvironmentProtocol {
    var snackBarSubject: CurrentValueSubject<SnackBarType?, Never> { get }
    
    func showSnackBar(_ type: SnackBarType)
}