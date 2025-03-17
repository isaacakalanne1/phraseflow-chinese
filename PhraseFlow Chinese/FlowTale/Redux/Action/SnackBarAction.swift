//
//  SnackbarAction.swift
//  FlowTale
//
//  Created by iakalann on 22/03/2025.
//

enum SnackBarAction {
    case showSnackBar(SnackBarType)
    case hideSnackbar
    case showSnackBarThenSaveStory(SnackBarType, Story)
}
