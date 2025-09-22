//
//  SnackBarSubscriber.swift
//  SnackBar
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import ReduxKit

@MainActor
let snackBarSubscriber: OnSubscribe<SnackBarStore, SnackBarEnvironmentProtocol> = { store, environment in
    
    environment.snackbarStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak store] snackbarType in
                guard let store else {
                    return
                }
                store.dispatch(.setType(snackbarType))
            }
            .store(in: &store.subscriptions)
    
}
