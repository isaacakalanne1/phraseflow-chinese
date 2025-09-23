//
//  TextPracticeEnvironmentProtocol.swift
//  TextPractice
//
//  Created by Isaac Akalanne on 02/09/2025.
//

import Foundation
import Audio
import Combine
import TextGeneration
import Settings
import Study

public protocol TextPracticeEnvironmentProtocol {
    var definitionsSubject: CurrentValueSubject<[Definition]?, Never> { get }
    var goToNextChapterSubject: CurrentValueSubject<Void?, Never> { get }
    var settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never> { get }
    var chapterAudioDataSubject: CurrentValueSubject<Data?, Never> { get }
    
    var audioEnvironment: AudioEnvironmentProtocol { get }
    var studyEnvironment: StudyEnvironmentProtocol { get }
    
    func saveAppSettings(_ settings: SettingsState) throws
    
    func saveDefinitions(_ definitions: [Definition]) throws
    
    func addDefinitions(_ definitions: [Definition])
    func goToNextChapter()
    
    func prepareToPlayChapter(_ chapter: Chapter) async
    func setMusicVolume(_ volume: MusicVolume)
    func playSound(_ sound: AppSound)
    func saveSentenceAudio(_ audio: Data, id: UUID) throws
}
