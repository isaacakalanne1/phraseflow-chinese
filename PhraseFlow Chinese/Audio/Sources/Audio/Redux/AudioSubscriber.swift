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
    
    environment.chapterAudioDataSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak store] audioData in
                guard let store,
                let audioData else {
                    return
                }
                store.dispatch(.setChapterAudioData(audioData))
            }
            .store(in: &store.subscriptions)
    
    environment.playChapterAudioSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak store] params in
                guard let store,
                let params else {
                    return
                }
                store.dispatch(.playChapterAudio(time: params.time, rate: params.rate))
            }
            .store(in: &store.subscriptions)
    
    environment.pauseChapterAudioSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak store] shouldPause in
                guard let store,
                shouldPause else {
                    return
                }
                store.dispatch(.pauseChapterAudio)
            }
            .store(in: &store.subscriptions)
    
    environment.playWordSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak store] params in
                guard let store,
                let params else {
                    return
                }
                store.dispatch(.playWord(startTime: params.startTime, duration: params.duration, playRate: params.playRate))
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
    
    environment.updatePlaybackRateSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak store] playRate in
                guard let store,
                let playRate else {
                    return
                }
                store.dispatch(.updatePlaybackRate(playRate))
            }
            .store(in: &store.subscriptions)
}
