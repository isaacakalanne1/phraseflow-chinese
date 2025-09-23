//
//  AudioSubscriber.swift
//  Audio
//
//  Created by Isaac Akalanne on 23/09/2025.
//

import Foundation
import ReduxKit
import Combine

@MainActor
let audioSubscriber: OnSubscribe<AudioStore, AudioEnvironmentProtocol> = { store, environment in
    
    environment.appSoundSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak store] sound in
                guard let store,
                let sound else {
                    return
                }
                store.dispatch(.playSound(sound))
            }
            .store(in: &store.subscriptions)
}
