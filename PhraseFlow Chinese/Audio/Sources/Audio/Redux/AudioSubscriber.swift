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
    
    environment.playMusicSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak store] params in
                guard let store,
                let params else {
                    return
                }
                store.dispatch(.playMusic(music: params.music, volume: params.volume))
            }
            .store(in: &store.subscriptions)
    
    environment.stopMusicSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak store] shouldStop in
                guard let store,
                shouldStop else {
                    return
                }
                store.dispatch(.stopMusic)
            }
            .store(in: &store.subscriptions)
    
    environment.setMusicVolumeSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak store] volume in
                guard let store,
                let volume else {
                    return
                }
                store.dispatch(.setMusicVolume(volume))
            }
            .store(in: &store.subscriptions)
    
    environment.musicFinishedSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak store] finished in
                guard let store,
                finished else {
                    return
                }
                store.dispatch(.musicFinished)
            }
            .store(in: &store.subscriptions)
    
}
