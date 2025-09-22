//
//  AppSoundTests.swift
//  Audio
//
//  Created by Isaac Akalanne on 22/09/2025.
//

import Testing
@testable import Audio

class AppSoundTests {
    
    @Test
    func actionButtonPress() {
        let sound = AppSound.actionButtonPress
        #expect(sound.rawValue == "actionButtonPress")
        #expect(sound.fileURL?.lastPathComponent == "ActionButtonPress.mp3")
    }
    
    @Test
    func changeSettings() {
        let sound = AppSound.changeSettings
        #expect(sound.rawValue == "changeSettings")
        #expect(sound.fileURL?.lastPathComponent == "ChangeSettings.mp3")
    }
    
    @Test
    func togglePress() {
        let sound = AppSound.togglePress
        #expect(sound.rawValue == "togglePress")
        #expect(sound.fileURL?.lastPathComponent == "TogglePress.mp3")
    }
    
    @Test
    func largeHorns() {
        let sound = AppSound.largeHorns
        #expect(sound.rawValue == "largeHorns")
        #expect(sound.fileURL?.lastPathComponent == "LargeHorns.mp3")
    }
    
    @Test
    func largeBoom() {
        let sound = AppSound.largeBoom
        #expect(sound.rawValue == "largeBoom")
        #expect(sound.fileURL?.lastPathComponent == "LargeBoom.mp3")
    }
    
    @Test
    func chunkyHit() {
        let sound = AppSound.chunkyHit
        #expect(sound.rawValue == "chunkyHit")
        #expect(sound.fileURL?.lastPathComponent == "ChunkyHit.mp3")
    }
    
    @Test
    func tabPress() {
        let sound = AppSound.tabPress
        #expect(sound.rawValue == "tabPress")
        #expect(sound.fileURL?.lastPathComponent == "TabPress.mp3")
    }
    
    @Test
    func backButtonPress() {
        let sound = AppSound.backButtonPress
        #expect(sound.rawValue == "backButtonPress")
        #expect(sound.fileURL?.lastPathComponent == "BackButtonPress.mp3")
    }
    
    @Test
    func openStory() {
        let sound = AppSound.openStory
        #expect(sound.rawValue == "openStory")
        #expect(sound.fileURL?.lastPathComponent == "OpenStory.mp3")
    }
    
    @Test
    func openChapter() {
        let sound = AppSound.openChapter
        #expect(sound.rawValue == "openChapter")
        #expect(sound.fileURL?.lastPathComponent == "OpenChapter.mp3")
    }
    
    @Test
    func snackbar() {
        let sound = AppSound.snackbar
        #expect(sound.rawValue == "snackbar")
        #expect(sound.fileURL?.lastPathComponent == "Snackbar.mp3")
    }
    
    @Test
    func errorSnackbar() {
        let sound = AppSound.errorSnackbar
        #expect(sound.rawValue == "errorSnackbar")
        #expect(sound.fileURL?.lastPathComponent == "ErrorSnackbar.mp3")
    }
    
    @Test
    func progressUpdate() {
        let sound = AppSound.progressUpdate
        #expect(sound.rawValue == "progressUpdate")
        #expect(sound.fileURL?.lastPathComponent == "ProgressUpdate.mp3")
    }
    
    @Test
    func openStorySettings() {
        let sound = AppSound.openStorySettings
        #expect(sound.rawValue == "openStorySettings")
        #expect(sound.fileURL?.lastPathComponent == "OpenStorySettings.mp3")
    }
    
    @Test
    func createStory() {
        let sound = AppSound.createStory
        #expect(sound.rawValue == "createStory")
        #expect(sound.fileURL?.lastPathComponent == "CreateStory.mp3")
    }
    
    @Test
    func nextStudyWord() {
        let sound = AppSound.nextStudyWord
        #expect(sound.rawValue == "nextStudyWord")
        #expect(sound.fileURL?.lastPathComponent == "NextStudyWord.mp3")
    }
    
    @Test
    func previousStudyWord() {
        let sound = AppSound.previousStudyWord
        #expect(sound.rawValue == "previousStudyWord")
        #expect(sound.fileURL?.lastPathComponent == "PreviousStudyWord.mp3")
    }
    
    @Test
    func createNextChapter() {
        let sound = AppSound.createNextChapter
        #expect(sound.rawValue == "createNextChapter")
        #expect(sound.fileURL?.lastPathComponent == "CreateNextChapter.mp3")
    }
    
    @Test
    func goToNextChapter() {
        let sound = AppSound.goToNextChapter
        #expect(sound.rawValue == "goToNextChapter")
        #expect(sound.fileURL?.lastPathComponent == "GoToNextChapter.mp3")
    }
}
