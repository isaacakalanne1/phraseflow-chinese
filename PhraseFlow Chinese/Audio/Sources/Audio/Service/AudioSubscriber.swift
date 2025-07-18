//
//  AudioSubscriber.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import ReduxKit

let audioSubscriber: OnSubscribe<FlowTaleStore, AudioEnvironmentProtocol> = { store, environment in
    
    store
        .subscribe(
            environment.appSoundSubject
        ) { store, appSound in
            if let appSound = appSound {
                store.dispatch(.audioAction(.playSound(appSound)))
            }
        }
}