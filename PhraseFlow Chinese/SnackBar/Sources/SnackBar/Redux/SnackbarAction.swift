//
//  SnackbarAction.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation

public enum SnackBarAction: Sendable, Equatable {
    case showSnackBar(SnackBarType)
    case hideSnackbar
    case checkDeviceVolumeZero
}
