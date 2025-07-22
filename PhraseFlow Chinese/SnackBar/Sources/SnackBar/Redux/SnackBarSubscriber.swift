//
//  SnackBarSubscriber.swift
//  SnackBar
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import ReduxKit

let snackBarSubscriber: OnSubscribe<SnackBarStore, SnackBarEnvironmentProtocol> = { store, environment in
    store
        .subscribe(
            environment.snackBarSubject
        ) { store, snackBarType in
            guard let snackBarType = snackBarType else { return }
            store.dispatch(.snackbarAction(.showSnackBar(snackBarType)))
        }
}
