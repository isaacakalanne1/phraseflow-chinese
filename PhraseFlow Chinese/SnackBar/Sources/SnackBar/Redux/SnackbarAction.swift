//
//  SnackbarAction.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation
import TextGeneration

public enum SnackBarAction {
    case showSnackBar(SnackBarType)
    case hideSnackbar
    case showSnackBarThenSaveChapter(SnackBarType, Chapter)
    case hideSnackbarThenSaveChapterAndSettings(Chapter)
    case checkDeviceVolumeZero
}
