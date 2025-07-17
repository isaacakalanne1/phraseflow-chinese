//
//  SnackbarAction.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation

enum SnackbarAction {
    case showSnackBar(SnackBarType)
    case hideSnackbar
    case showSnackBarThenSaveChapter(SnackBarType, Chapter)
    case hideSnackbarThenSaveChapterAndSettings(Chapter)
    case checkDeviceVolumeZero
}
