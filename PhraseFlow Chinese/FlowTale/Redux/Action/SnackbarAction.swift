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
    case showSnackBarThenSaveStory(SnackBarType, Story)
    case hideSnackbarThenSaveStoryAndSettings(Story)
}