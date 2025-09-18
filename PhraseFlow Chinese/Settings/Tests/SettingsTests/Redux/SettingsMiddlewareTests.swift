//
//  SettingsMiddlewareTests.swift
//  Settings
//
//  Created by Isaac Akalanne on 19/09/2025.
//

import Testing
@testable import Settings
@testable import SettingsMocks
@testable import Moderation
@testable import ModerationMocks

final class SettingsMiddlewareTests {
    
    let mockEnvironment: MockSettingsEnvironment
    
    init() {
        mockEnvironment = MockSettingsEnvironment()
    }
    
    @Test
    func loadAppSettings_success() async throws {
        let expectedSettings: SettingsState = .arrange(usedCharacters: 999)
        mockEnvironment.loadAppSettingsResult = .success(expectedSettings)

        let resultAction = await settingsMiddleware(
            .arrange,
            .loadAppSettings,
            mockEnvironment
        )

        #expect(resultAction == .onLoadedAppSettings(expectedSettings))
        #expect(mockEnvironment.loadAppSettingsCalled == true)
    }
    
    @Test
    func loadAppSettings_error() async throws {
        mockEnvironment.loadAppSettingsResult = .failure(.genericError)

        let resultAction = await settingsMiddleware(
            .arrange,
            .loadAppSettings,
            mockEnvironment
        )

        #expect(resultAction == .failedToLoadAppSettings)
        #expect(mockEnvironment.loadAppSettingsCalled == true)
    }
    
    @Test
    func saveAppSettings_success() async throws {
        let state: SettingsState = .arrange(usedCharacters: 100)
        mockEnvironment.saveAppSettingsResult = .success(())

        let resultAction = await settingsMiddleware(
            state,
            .saveAppSettings,
            mockEnvironment
        )

        #expect(resultAction == nil)
        #expect(mockEnvironment.saveAppSettingsCalled == true)
        #expect(mockEnvironment.saveAppSettingsSpy == state)
    }
    
    @Test
    func saveAppSettings_error() async throws {
        let state: SettingsState = .arrange(usedCharacters: 100)
        mockEnvironment.saveAppSettingsResult = .failure(.genericError)

        let resultAction = await settingsMiddleware(
            state,
            .saveAppSettings,
            mockEnvironment
        )

        #expect(resultAction == .failedToSaveAppSettings)
        #expect(mockEnvironment.saveAppSettingsCalled == true)
    }
    
    @Test
    func selectVoice_shouldTriggerSaveAppSettings() async throws {
        let resultAction = await settingsMiddleware(
            .arrange,
            .selectVoice(.elvira),
            mockEnvironment
        )

        #expect(resultAction == .saveAppSettings)
    }
    
    @Test
    func updateShowDefinition_shouldTriggerSaveAppSettings() async throws {
        let resultAction = await settingsMiddleware(
            .arrange,
            .updateShowDefinition(true),
            mockEnvironment
        )

        #expect(resultAction == .saveAppSettings)
    }
    
    @Test
    func updateShowEnglish_shouldTriggerSaveAppSettings() async throws {
        let resultAction = await settingsMiddleware(
            .arrange,
            .updateShowEnglish(false),
            mockEnvironment
        )

        #expect(resultAction == .saveAppSettings)
    }
    
    @Test
    func updateDifficulty_shouldTriggerSaveAppSettings() async throws {
        let resultAction = await settingsMiddleware(
            .arrange,
            .updateDifficulty(.intermediate),
            mockEnvironment
        )

        #expect(resultAction == .saveAppSettings)
    }
    
    @Test
    func updateShouldPlaySound_whenEnabled_playsToggleAndSaves() async throws {
        let state: SettingsState = .arrange(shouldPlaySound: true)
        
        let resultAction = await settingsMiddleware(
            state,
            .updateShouldPlaySound(true),
            mockEnvironment
        )

        #expect(resultAction == .saveAppSettings)
        #expect(mockEnvironment.playSoundCalled == true)
        #expect(mockEnvironment.playSoundSpy == .togglePress)
    }
    
    @Test
    func updateShouldPlaySound_whenDisabled_doesNotPlaySound() async throws {
        let state: SettingsState = .arrange(shouldPlaySound: false)
        
        let resultAction = await settingsMiddleware(
            state,
            .updateShouldPlaySound(false),
            mockEnvironment
        )

        #expect(resultAction == .saveAppSettings)
        #expect(mockEnvironment.playSoundCalled == false)
    }
    
    @Test
    func updateLanguage_whenSoundEnabled_playsTabPress() async throws {
        let state: SettingsState = .arrange(shouldPlaySound: true)
        
        let resultAction = await settingsMiddleware(
            state,
            .updateLanguage(.mandarinChinese),
            mockEnvironment
        )

        #expect(resultAction == .saveAppSettings)
        #expect(mockEnvironment.playSoundCalled == true)
        #expect(mockEnvironment.playSoundSpy == .tabPress)
    }
    
    @Test
    func updateLanguage_whenSoundDisabled_doesNotPlaySound() async throws {
        let state: SettingsState = .arrange(shouldPlaySound: false)
        
        let resultAction = await settingsMiddleware(
            state,
            .updateLanguage(.spanish),
            mockEnvironment
        )

        #expect(resultAction == .saveAppSettings)
        #expect(mockEnvironment.playSoundCalled == false)
    }
    
    @Test
    func onLoadedAppSettings_whenMusicShouldPlay_startsMusic() async throws {
        let state: SettingsState = .arrange(isPlayingMusic: true)
        let loadedSettings: SettingsState = .arrange(isPlayingMusic: true)
        mockEnvironment.isPlayingMusic = false

        let resultAction = await settingsMiddleware(
            state,
            .onLoadedAppSettings(loadedSettings),
            mockEnvironment
        )

        #expect(resultAction == .playMusic(.whispersOfTheForest))
    }
    
    @Test
    func onLoadedAppSettings_whenMusicAlreadyPlaying_doesNothing() async throws {
        let state: SettingsState = .arrange(isPlayingMusic: true)
        let loadedSettings: SettingsState = .arrange(isPlayingMusic: true)
        mockEnvironment.isPlayingMusic = true

        let resultAction = await settingsMiddleware(
            state,
            .onLoadedAppSettings(loadedSettings),
            mockEnvironment
        )

        #expect(resultAction == nil)
    }
    
    @Test
    func onLoadedAppSettings_whenMusicDisabled_doesNothing() async throws {
        let state: SettingsState = .arrange(isPlayingMusic: false)
        let loadedSettings: SettingsState = .arrange(isPlayingMusic: false)
        mockEnvironment.isPlayingMusic = false

        let resultAction = await settingsMiddleware(
            state,
            .onLoadedAppSettings(loadedSettings),
            mockEnvironment
        )

        #expect(resultAction == nil)
    }
    
    @Test
    func playSound_whenSoundEnabled_playsSound() async throws {
        let state: SettingsState = .arrange(shouldPlaySound: true)
        
        let resultAction = await settingsMiddleware(
            state,
            .playSound(.actionButtonPress),
            mockEnvironment
        )

        #expect(resultAction == nil)
        #expect(mockEnvironment.playSoundCalled == true)
        #expect(mockEnvironment.playSoundSpy == .actionButtonPress)
    }
    
    @Test
    func playSound_whenSoundDisabled_doesNotPlaySound() async throws {
        let state: SettingsState = .arrange(shouldPlaySound: false)
        
        let resultAction = await settingsMiddleware(
            state,
            .playSound(.actionButtonPress),
            mockEnvironment
        )

        #expect(resultAction == nil)
        #expect(mockEnvironment.playSoundCalled == false)
    }
    
    @Test
    func playMusic_triggersPlayAndSave() async throws {
        mockEnvironment.playMusicResult = .success(())
        
        let resultAction = await settingsMiddleware(
            .arrange,
            .playMusic(.whispersOfTheForest),
            mockEnvironment
        )

        #expect(resultAction == .saveAppSettings)
        #expect(mockEnvironment.playMusicCalled == true)
        #expect(mockEnvironment.playMusicSpy == .whispersOfTheForest)
    }
    
    @Test
    func playMusic_onError_stillSavesSettings() async throws {
        mockEnvironment.playMusicResult = .failure(.genericError)
        
        let resultAction = await settingsMiddleware(
            .arrange,
            .playMusic(.whispersOfTheForest),
            mockEnvironment
        )

        #expect(resultAction == .saveAppSettings)
        #expect(mockEnvironment.playMusicCalled == true)
    }
    
    @Test
    func stopMusic_stopsAndPlaysSoundIfEnabled() async throws {
        let state: SettingsState = .arrange(shouldPlaySound: true)
        
        let resultAction = await settingsMiddleware(
            state,
            .stopMusic,
            mockEnvironment
        )

        #expect(resultAction == .saveAppSettings)
        #expect(mockEnvironment.stopMusicCalled == true)
        #expect(mockEnvironment.playSoundCalled == true)
        #expect(mockEnvironment.playSoundSpy == .togglePress)
    }
    
    @Test
    func stopMusic_whenSoundDisabled_onlyStopsMusic() async throws {
        let state: SettingsState = .arrange(shouldPlaySound: false)
        
        let resultAction = await settingsMiddleware(
            state,
            .stopMusic,
            mockEnvironment
        )

        #expect(resultAction == .saveAppSettings)
        #expect(mockEnvironment.stopMusicCalled == true)
        #expect(mockEnvironment.playSoundCalled == false)
    }
    
    @Test
    func updateStorySetting_shouldTriggerSaveAppSettings() async throws {
        let resultAction = await settingsMiddleware(
            .arrange,
            .updateStorySetting(.random),
            mockEnvironment
        )

        #expect(resultAction == .saveAppSettings)
    }
    
    @Test
    func deleteCustomPrompt_shouldTriggerSaveAppSettings() async throws {
        let resultAction = await settingsMiddleware(
            .arrange,
            .deleteCustomPrompt("test prompt"),
            mockEnvironment
        )

        #expect(resultAction == .saveAppSettings)
    }
    
    @Test
    func submitCustomPrompt_whenPassesModeration_updatesStorySetting() async throws {
        let prompt = "A nice story about cats"
        
        let moderationResponse = ModerationResponse.arrange(results: [
            .arrange(category_scores: [ModerationCategories.violenceGraphic.key: 0.1])
        ])
        mockEnvironment.moderateTextResult = .success(moderationResponse)
        
        let resultAction = await settingsMiddleware(
            .arrange,
            .submitCustomPrompt(prompt),
            mockEnvironment
        )

        #expect(resultAction == .updateStorySetting(.customPrompt(prompt)))
        #expect(mockEnvironment.moderateTextCalled == true)
        #expect(mockEnvironment.moderateTextSpy == prompt)
    }
    
    @Test
    func submitCustomPrompt_whenFailsModeration_updatesModerationResponse() async throws {
        let prompt = "An inappropriate prompt"
        let moderationResponse = ModerationResponse.arrange(results: [
            .arrange(category_scores: [ModerationCategories.violenceGraphic.key: 0.9])
        ])
        mockEnvironment.moderateTextResult = .success(moderationResponse)
        
        let resultAction = await settingsMiddleware(
            .arrange,
            .submitCustomPrompt(prompt),
            mockEnvironment
        )

        #expect(resultAction == .updateModerationResponse(moderationResponse))
        #expect(mockEnvironment.moderateTextCalled == true)
        #expect(mockEnvironment.moderateTextSpy == prompt)
    }
    
    @Test
    func submitCustomPrompt_whenModerationErrors_showsAlert() async throws {
        let prompt = "A story prompt"
        mockEnvironment.moderateTextResult = .failure(.genericError)
        
        let resultAction = await settingsMiddleware(
            .arrange,
            .submitCustomPrompt(prompt),
            mockEnvironment
        )

        #expect(resultAction == .updateIsShowingModerationFailedAlert(true))
        #expect(mockEnvironment.moderateTextCalled == true)
        #expect(mockEnvironment.moderateTextSpy == prompt)
    }
    
    @Test
    func failedToLoadAppSettings_returnsNil() async throws {
        let resultAction = await settingsMiddleware(
            .arrange,
            .failedToLoadAppSettings,
            mockEnvironment
        )

        #expect(resultAction == nil)
    }
    
    @Test
    func failedToSaveAppSettings_returnsNil() async throws {
        let resultAction = await settingsMiddleware(
            .arrange,
            .failedToSaveAppSettings,
            mockEnvironment
        )

        #expect(resultAction == nil)
    }
    
    @Test
    func updateCustomPrompt_returnsNil() async throws {
        let resultAction = await settingsMiddleware(
            .arrange,
            .updateCustomPrompt("new prompt"),
            mockEnvironment
        )

        #expect(resultAction == nil)
    }
    
    @Test
    func updateIsShowingCustomPromptAlert_returnsNil() async throws {
        let resultAction = await settingsMiddleware(
            .arrange,
            .updateIsShowingCustomPromptAlert(true),
            mockEnvironment
        )

        #expect(resultAction == nil)
    }
    
    @Test
    func updateIsShowingModerationFailedAlert_returnsNil() async throws {
        let resultAction = await settingsMiddleware(
            .arrange,
            .updateIsShowingModerationFailedAlert(false),
            mockEnvironment
        )

        #expect(resultAction == nil)
    }
    
    @Test
    func updateIsShowingModerationDetails_returnsNil() async throws {
        let resultAction = await settingsMiddleware(
            .arrange,
            .updateIsShowingModerationDetails(true),
            mockEnvironment
        )

        #expect(resultAction == nil)
    }
    
    @Test
    func updateModerationResponse_returnsNil() async throws {
        let resultAction = await settingsMiddleware(
            .arrange,
            .updateModerationResponse(.arrange),
            mockEnvironment
        )

        #expect(resultAction == nil)
    }
    
    @Test
    func snackbarAction_returnsNil() async throws {
        let resultAction = await settingsMiddleware(
            .arrange,
            .snackbarAction(.showSnackBar(.chapterReady)),
            mockEnvironment
        )

        #expect(resultAction == nil)
    }
    
    @Test
    func refreshAppSettings_returnsNil() async throws {
        let resultAction = await settingsMiddleware(
            .arrange,
            .refreshAppSettings(.arrange),
            mockEnvironment
        )

        #expect(resultAction == nil)
    }
}
