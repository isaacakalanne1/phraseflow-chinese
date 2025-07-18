//
//  SnackBarSubscriber.swift
//  SnackBar
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import ReduxKit

class SnackBarSubscriber {
    static func initialize(store: FlowTaleStore, environment: SnackBarEnvironmentProtocol) {
        
        store.subscribe(environment.snackBarSubject) { store, snackBarType in
            guard let snackBarType = snackBarType else { return }
            store.dispatch(.snackbarAction(.showSnackBar(snackBarType)))
        }
    }
}